import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'dart:async'; // Ajout pour StreamSubscription
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:projet_flutter/athkar_page.dart';
import 'package:projet_flutter/welcome_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

String toArabicNumbers(String input) {
  const english = '0123456789';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  return input
      .split('')
      .map((char) =>
          english.contains(char) ? arabic[english.indexOf(char)] : char)
      .join('');
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'آياتنا وأذكارنا',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF234F1E),
          primary: const Color(0xFF234F1E),
          secondary: const Color(0xFFBFA676),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F3E6),
        textTheme: GoogleFonts.amiriQuranTextTheme(),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF234F1E),
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
              fontFamily: 'AmiriQuran', fontSize: 24, color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFFF8F3E6),
          selectedItemColor: const Color(0xFF234F1E),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
              fontFamily: 'AmiriQuran', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'AmiriQuran'),
        ),
      ),
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    AthkarPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'القرآن',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined),
            label: 'الأذكار',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> surahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSurahs();
  }

  Future<void> fetchSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            surahs = data['data'];
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          // Gérer l'erreur
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('خطأ'),
              content: Text('خطأ في تحميل السور: ${e.toString()}'),
              actions: [
                TextButton(
                  child: const Text('حسناً'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المصحف الشريف',
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F3E6),
              const Color(0xFFE8DCC0),
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.black.withOpacity(0.3),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SurahDetailPage(
                              surahNumber: surah['number'],
                              surahName: surah['name'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              const Color(0xFFBFA676).withOpacity(0.1),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                              ),
                              child: Text(
                                toArabicNumbers('${surah['number']}'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              surah['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF234F1E),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${toArabicNumbers(surah['numberOfAyahs'].toString())} آية',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class Reciter {
  final String name;
  final String alquranCloudIdentifier; // Identifiant pour alquran.cloud

  Reciter({required this.name, required this.alquranCloudIdentifier});
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<dynamic> ayahs = [];
  bool isLoading = true;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isDisposed = false;
  bool _isAudioReady = false;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;
  bool _isLoadingAudio = false;
  String? _audioError;

  // Récitateurs disponibles pour l'audio de la sourate entière (via cdn_surah_audio.json)
  static const List<String> _surahAudioReciterIdentifiers = [
    "ar.alafasy",
    "ar.abdulbasitmurattal",
    "ar.ahmedalajmi",
  ];

  final List<Reciter> reciters = [
    Reciter(
        name: "عبد الرحمن السديس",
        alquranCloudIdentifier: "ar.abdurrahmaansudais"),
    Reciter(name: "ماهر المعيقلي", alquranCloudIdentifier: "ar.mahermuaiqly"),
    Reciter(name: "مشاري راشد العفاسي", alquranCloudIdentifier: "ar.alafasy"),
    Reciter(
        name: "عبد الباسط عبد الصمد (مرتل)",
        alquranCloudIdentifier: "ar.abdulbasitmurattal"),
    Reciter(
        name: "أحمد بن علي العجمي", alquranCloudIdentifier: "ar.ahmedalajmi"),
  ];
  late Reciter _selectedReciter;

  @override
  void initState() {
    super.initState();
    _selectedReciter = reciters.first;
    print(
        "SurahDetailPage initState: Surah ${widget.surahNumber}, Reciter: ${_selectedReciter.alquranCloudIdentifier}");
    _initAudioPlayer();
    fetchSurahDataAndPrepareAudio();
  }

  void _initAudioPlayer() {
    _audioPlayer?.dispose();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer?.setVolume(1.0);
    _audioPlayer?.setLoopMode(LoopMode.off);

    _playerStateSubscription?.cancel();
    _processingStateSubscription?.cancel();

    _playerStateSubscription = _audioPlayer?.playerStateStream.listen((state) {
      if (!mounted) return;
      print(
          "AudioPlayer State: Playing=${state.playing}, ProcessingState=${state.processingState}");
      if (_isPlaying != state.playing) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _processingStateSubscription =
        _audioPlayer?.processingStateStream.listen((state) {
      if (!mounted) return;
      print(
          "AudioPlayer ProcessingState: $state. Current _isAudioReady before check: $_isAudioReady");

      bool newAudioReadyState = state == ProcessingState.ready;
      if (_isAudioReady != newAudioReadyState) {
        print(
            "Setting _isAudioReady to $newAudioReadyState based on ProcessingState $state");
        setState(() {
          _isAudioReady = newAudioReadyState;
        });
      }

      if (state == ProcessingState.completed) {
        print("Audio processing state: COMPLETED. Ayah/Surah finished.");
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    }, onError: (error) {
      print("Error in processing state stream: $error");
      _handleAudioError(error);
    });
  }

  void _handleAudioError(dynamic error) {
    if (!mounted) return;
    print("Handling audio error: $error");
    setState(() {
      _isPlaying = false;
      _isAudioReady = false;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("خطأ في الصوت"),
        content: Text("حدث خطأ أثناء تشغيل الصوت: ${error.toString()}"),
        actions: [
          TextButton(
            child: const Text("إعادة المحاولة"),
            onPressed: () {
              Navigator.pop(context);
              _initAudioPlayer();
              fetchSurahDataAndPrepareAudio();
            },
          ),
          TextButton(
            child: const Text("حسناً"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> fetchSurahDataAndPrepareAudio() async {
    print(
        "fetchSurahDataAndPrepareAudio for Surah ${widget.surahNumber} with reciter ${_selectedReciter.alquranCloudIdentifier}");
    if (!mounted) {
      print("fetchSurahDataAndPrepareAudio aborted: not mounted");
      return;
    }

    setState(() {
      isLoading = true;
      _isAudioReady = false;
    });

    try {
      // Arrêter la lecture en cours si nécessaire
      if (_audioPlayer!.playing) {
        await _audioPlayer!.stop();
      }

      // Récupérer les détails de la sourate
      final response = await http
          .get(
            Uri.parse(
                'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/quran-uthmani'),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('La connexion a expiré (30 secondes)'),
          );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ayahs = data['data']['ayahs'];
          print(
              "Fetched ${ayahs.length} ayahs for Surah ${widget.surahNumber}");
        });

        if (ayahs.isNotEmpty) {
          await _prepareAudio();
        }
      } else {
        throw Exception('فشل تحميل السورة (${response.statusCode})');
      }
    } catch (e) {
      print("Error in fetchSurahDataAndPrepareAudio: $e");
      if (mounted) {
        _handleError(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _prepareAudio() async {
    if (_isLoadingAudio || widget.surahNumber == -1) return;

    setState(() {
      _isLoadingAudio = true;
      _audioError = null;
    });

    String surahAudioUrl =
        ""; // Déclarée ici pour être accessible dans le catch

    try {
      AudioSource audioSource;

      if (_surahAudioReciterIdentifiers
          .contains(_selectedReciter.alquranCloudIdentifier)) {
        // Utiliser l'URL directe du CDN pour l'audio de la sourate entière
        surahAudioUrl =
            "https://cdn.islamic.network/quran/audio-surah/128/${_selectedReciter.alquranCloudIdentifier}/${widget.surahNumber}.mp3";
        print(
            "Preparing single audio source (surah) for Surah ${widget.surahNumber} with reciter ${_selectedReciter.alquranCloudIdentifier}: $surahAudioUrl");
        if (kIsWeb) {
          audioSource = AudioSource.uri(Uri.parse(surahAudioUrl));
        } else {
          audioSource = LockCachingAudioSource(Uri.parse(surahAudioUrl));
        }
      } else {
        // Pour les autres récitateurs (ex: Sudais, Maher), charger verset par verset
        print(
            "Preparing concatenated audio source (verse by verse) for Surah ${widget.surahNumber} with reciter ${_selectedReciter.alquranCloudIdentifier}");

        // S'assurer que les ayahs sont chargés avec les données audio du récitateur sélectionné
        // Cet appel est crucial si fetchSurahDataAndPrepareAudio ne charge pas déjà les données audio du récitateur
        final response = await http
            .get(
              Uri.parse(
                  'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/${_selectedReciter.alquranCloudIdentifier}'),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => throw TimeoutException(
                  'Timeout (30s) fetching verse audio data for ${_selectedReciter.alquranCloudIdentifier}'),
            );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['data'] == null || data['data']['ayahs'] == null) {
            throw Exception(
                'No audio data found for ayahs with reciter ${_selectedReciter.alquranCloudIdentifier}');
          }
          final ayahsWithAudio = data['data']['ayahs'] as List<dynamic>;

          if (ayahsWithAudio.isEmpty) {
            throw Exception(
                'Empty ayahs list for reciter ${_selectedReciter.alquranCloudIdentifier}');
          }

          List<AudioSource> audioSources = [];
          for (var ayahData in ayahsWithAudio) {
            if (ayahData['audio'] != null &&
                (ayahData['audio'] as String).isNotEmpty) {
              if (kIsWeb) {
                audioSources.add(
                    AudioSource.uri(Uri.parse(ayahData['audio'] as String)));
              } else {
                // Pourrait envisager LockCachingAudioSource ici aussi si nécessaire, mais la mise en cache de nombreux petits fichiers peut être moins efficace.
                // Pour l'instant, utilisons AudioSource.uri pour la simplicité, puis nous pourrons optimiser si besoin.
                audioSources.add(
                    AudioSource.uri(Uri.parse(ayahData['audio'] as String)));
              }
            }
          }

          if (audioSources.isEmpty) {
            throw Exception(
                'No valid audio URLs found for any ayahs with reciter ${_selectedReciter.alquranCloudIdentifier}');
          }
          audioSource = ConcatenatingAudioSource(children: audioSources);
          print(
              "Concatenated audio source created with ${audioSources.length} ayahs for ${_selectedReciter.alquranCloudIdentifier}.");
        } else {
          throw Exception(
              'Failed to load verse audio data for ${_selectedReciter.alquranCloudIdentifier} (Status: ${response.statusCode})');
        }
      }

      // audioSource = AudioSource.uri(Uri.parse(surahAudioUrl)); // TEST: Utiliser AudioSource.uri partout -- COMMENTÉ

      // Il n'est plus nécessaire de récupérer les données des ayahs juste pour l'audio
      // si nous utilisons l'audio de la sourate entière.
      // Cependant, nous en avons toujours besoin pour l'affichage du texte de la sourate.
      // Assurons-nous que fetchSurahData (appelé par fetchSurahDataAndPrepareAudio) est toujours exécuté.

      if (_audioPlayer == null) {
        _initAudioPlayer();
      }
      await _audioPlayer!.setAudioSource(audioSource,
          initialPosition: Duration.zero, preload: true);
      print("Audio source set successfully for Surah ${widget.surahNumber}");
      setState(() {
        _isLoadingAudio = false;
      });
    } catch (e) {
      print(
          "Error preparing audio for Surah ${widget.surahNumber} with reciter ${_selectedReciter.alquranCloudIdentifier}: $e");
      print("URL tentée : $surahAudioUrl");
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
          _audioError = "Erreur de chargement audio: ${e.toString()}";
        });
      }
      _handleAudioError(
          "Erreur lors de la préparation de l'audio (CDN Surah): $e");
    }
  }

  void _handleError(dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("خطأ"),
        content: Text(error.toString().contains("Exception:")
            ? error.toString().replaceAll("Exception: ", "")
            : "حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى."),
        actions: [
          TextButton(
            child: const Text("إعادة المحاولة"),
            onPressed: () {
              Navigator.pop(context);
              _initAudioPlayer();
              fetchSurahDataAndPrepareAudio();
            },
          ),
          TextButton(
            child: const Text("حسناً"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _togglePlay() async {
    if (!mounted || isLoading || !_isAudioReady || _audioPlayer == null) {
      print("_togglePlay aborted: not mounted, loading, or audio not ready");
      if (!_isAudioReady && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("تنبيه"),
            content: const Text("جاري تحميل الملف الصوتي، الرجاء الانتظار..."),
            actions: [
              TextButton(
                child: const Text("إعادة المحاولة"),
                onPressed: () {
                  Navigator.pop(context);
                  _initAudioPlayer();
                  fetchSurahDataAndPrepareAudio();
                },
              ),
              TextButton(
                child: const Text("حسناً"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
      return;
    }

    try {
      if (_audioPlayer!.playing) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.play();
      }
    } catch (e) {
      _handleAudioError(e);
    }
  }

  void _showReciterMenu() async {
    if (!mounted || isLoading) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Reciter? selected = await showMenu<Reciter>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 100,
        offset.dy - 120,
        MediaQuery.of(context).size.width,
        offset.dy,
      ),
      items: reciters.map((Reciter reciter) {
        return PopupMenuItem<Reciter>(
          value: reciter,
          child: Text(
            reciter.name,
            style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 18),
            textDirection: TextDirection.rtl,
          ),
        );
      }).toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );

    if (selected != null &&
        selected.alquranCloudIdentifier !=
            _selectedReciter.alquranCloudIdentifier) {
      if (!mounted) return;
      print(
          "Changing reciter to: ${selected.name} (${selected.alquranCloudIdentifier})");

      // Modifications pour un rechargement plus robuste
      await _audioPlayer?.stop(); // Arrêter explicitement la lecture en cours
      _initAudioPlayer(); // Réinitialiser le lecteur audio

      setState(() {
        _selectedReciter = selected;
        _isPlaying = false;
        // isLoading = true; // Déjà géré dans fetchSurahDataAndPrepareAudio
      });
      await fetchSurahDataAndPrepareAudio();
    }
  }

  @override
  void dispose() {
    print("SurahDetailPage dispose called.");
    _isDisposed = true;
    _playerStateSubscription?.cancel();
    _processingStateSubscription?.cancel();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("SurahDetailPage build called. isLoading: $isLoading");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName, style: const TextStyle(fontSize: 28)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: _showReciterMenu,
            tooltip: 'اختر القارئ',
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F3E6),
              const Color(0xFFE8DCC0),
            ],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ayahs.isEmpty
                ? const Center(
                    child: Text('لا توجد آيات لتحميلها',
                        style:
                            TextStyle(fontFamily: 'AmiriQuran', fontSize: 20)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15.0),
                    child: Column(
                      children: [
                        if (widget.surahNumber != 1 && widget.surahNumber != 9)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              style: TextStyle(
                                fontFamily: 'AmiriQuran',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF234F1E),
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                                    offset: const Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        RichText(
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            children: ayahs.map<TextSpan>((ayah) {
                              return TextSpan(
                                text:
                                    "${ayah['text']} ﴿${toArabicNumbers(ayah['numberInSurah'].toString())}﴾ ",
                                style: TextStyle(
                                  fontFamily: 'AmiriQuran',
                                  fontSize: 26,
                                  height: 2.2,
                                  color: Colors.black87,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 2.0,
                                      color: const Color.fromRGBO(0, 0, 0, 0.1),
                                      offset: const Offset(0.5, 0.5),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: "play_pause_btn",
              onPressed: _togglePlay,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white,
                size: 36,
              ),
              tooltip: _isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
            ),
          ],
        ),
      ),
    );
  }
}
