/// Données de seed pour initialiser l'application avec des routines prédéfinies
/// Ces données sont utilisées au premier lancement pour avoir du contenu de base
library;

import 'package:spiritual_routines/core/models/task_category.dart';

class SeedData {
  /// Thèmes prédéfinis avec leurs routines
  static final themes = [
    {
      'id': 'theme_morning',
      'nameFr': 'Invocations du Matin',
      'nameAr': 'أذكار الصباح',
      'frequency': 'daily',
      'routines': [
        {
          'id': 'routine_morning_protection',
          'nameFr': 'Protection matinale',
          'nameAr': 'الحماية الصباحية',
          'tasks': [
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 112, // Al-Ikhlas
              'ayahStart': 1,
              'ayahEnd': 4,
              'defaultReps': 3,
              'notesFr': 'Réciter 3 fois pour la protection',
              'notesAr': 'قراءة 3 مرات للحماية',
            },
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 113, // Al-Falaq
              'ayahStart': 1,
              'ayahEnd': 5,
              'defaultReps': 3,
              'notesFr': 'Protection contre le mal',
              'notesAr': 'الحماية من الشر',
            },
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 114, // An-Nas
              'ayahStart': 1,
              'ayahEnd': 6,
              'defaultReps': 3,
              'notesFr': 'Protection contre les suggestions',
              'notesAr': 'الحماية من الوسوسة',
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
              'textFr': 'Gloire et louange à Allah',
              'defaultReps': 100,
              'notesFr': 'Poids léger sur la langue, lourd dans la balance',
            },
          ],
        },
        {
          'id': 'routine_morning_dhikr',
          'nameFr': 'Évocations essentielles',
          'nameAr': 'الأذكار الأساسية',
          'tasks': [
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
              'textFr': 'Il n\'y a de divinité qu\'Allah, Seul, sans associé',
              'defaultReps': 10,
            },
            {
              'type': 'text',
              'category': TaskCategory.gratitude,
              'textAr': 'الْحَمْدُ لِلَّهِ',
              'textFr': 'Louange à Allah',
              'defaultReps': 33,
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'سُبْحَانَ اللَّهِ',
              'textFr': 'Gloire à Allah',
              'defaultReps': 33,
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'اللَّهُ أَكْبَرُ',
              'textFr': 'Allah est le Plus Grand',
              'defaultReps': 34,
            },
          ],
        },
      ],
    },
    {
      'id': 'theme_evening',
      'nameFr': 'Invocations du Soir',
      'nameAr': 'أذكار المساء',
      'frequency': 'daily',
      'routines': [
        {
          'id': 'routine_evening_protection',
          'nameFr': 'Protection nocturne',
          'nameAr': 'الحماية الليلية',
          'tasks': [
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 2, // Ayat Al-Kursi
              'ayahStart': 255,
              'ayahEnd': 255,
              'defaultReps': 1,
              'notesFr': 'Le verset du Trône - Protection jusqu\'au matin',
              'notesAr': 'آية الكرسي - حماية حتى الصباح',
            },
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 2, // Derniers versets d'Al-Baqara
              'ayahStart': 285,
              'ayahEnd': 286,
              'defaultReps': 1,
              'notesFr': 'Les deux derniers versets de la Sourate Al-Baqara',
              'notesAr': 'آخر آيتين من سورة البقرة',
            },
            {
              'type': 'text',
              'category': TaskCategory.protection,
              'textAr':
                  'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
              'textFr':
                  'Au nom d\'Allah, avec Son nom rien ne peut nuire sur terre ni dans le ciel, et Il est l\'Audient, l\'Omniscient',
              'defaultReps': 3,
            },
          ],
        },
      ],
    },
    {
      'id': 'theme_prayer',
      'nameFr': 'Après la Prière',
      'nameAr': 'أذكار بعد الصلاة',
      'frequency': 'daily',
      'routines': [
        {
          'id': 'routine_after_prayer',
          'nameFr': 'Évocations après la prière',
          'nameAr': 'الأذكار بعد الصلاة',
          'tasks': [
            {
              'type': 'text',
              'category': TaskCategory.pardon,
              'textAr': 'أَسْتَغْفِرُ اللَّهَ',
              'textFr': 'Je demande pardon à Allah',
              'defaultReps': 3,
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr':
                  'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
              'textFr':
                  'Ô Allah, Tu es la Paix et de Toi vient la paix. Béni sois-Tu, ô Détenteur de la Majesté et de la Générosité',
              'defaultReps': 1,
            },
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 2,
              'ayahStart': 255,
              'ayahEnd': 255,
              'defaultReps': 1,
              'notesFr': 'Ayat Al-Kursi après chaque prière obligatoire',
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'سُبْحَانَ اللَّهِ',
              'textFr': 'Gloire à Allah',
              'defaultReps': 33,
            },
            {
              'type': 'text',
              'category': TaskCategory.gratitude,
              'textAr': 'الْحَمْدُ لِلَّهِ',
              'textFr': 'Louange à Allah',
              'defaultReps': 33,
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'اللَّهُ أَكْبَرُ',
              'textFr': 'Allah est le Plus Grand',
              'defaultReps': 34,
            },
          ],
        },
      ],
    },
    {
      'id': 'theme_sleep',
      'nameFr': 'Avant de Dormir',
      'nameAr': 'أذكار النوم',
      'frequency': 'daily',
      'routines': [
        {
          'id': 'routine_before_sleep',
          'nameFr': 'Invocations du coucher',
          'nameAr': 'أذكار قبل النوم',
          'tasks': [
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 112,
              'ayahStart': 1,
              'ayahEnd': 4,
              'defaultReps': 1,
              'notesFr': 'Souffler dans les mains et essuyer le corps',
            },
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 113,
              'ayahStart': 1,
              'ayahEnd': 5,
              'defaultReps': 1,
            },
            {
              'type': 'verses',
              'category': TaskCategory.protection,
              'surah': 114,
              'ayahStart': 1,
              'ayahEnd': 6,
              'defaultReps': 1,
            },
            {
              'type': 'text',
              'category': TaskCategory.guidance,
              'textAr': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
              'textFr': 'En Ton nom, ô Allah, je meurs et je vis',
              'defaultReps': 1,
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'سُبْحَانَ اللَّهِ',
              'textFr': 'Gloire à Allah',
              'defaultReps': 33,
            },
            {
              'type': 'text',
              'category': TaskCategory.gratitude,
              'textAr': 'الْحَمْدُ لِلَّهِ',
              'textFr': 'Louange à Allah',
              'defaultReps': 33,
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'اللَّهُ أَكْبَرُ',
              'textFr': 'Allah est le Plus Grand',
              'defaultReps': 34,
            },
          ],
        },
      ],
    },
    {
      'id': 'theme_healing',
      'nameFr': 'Guérison et Apaisement',
      'nameAr': 'الشفاء والسكينة',
      'frequency': 'weekly',
      'routines': [
        {
          'id': 'routine_healing',
          'nameFr': 'Invocations de guérison',
          'nameAr': 'أدعية الشفاء',
          'tasks': [
            {
              'type': 'text',
              'category': TaskCategory.healing,
              'textAr':
                  'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِ أَنْتَ الشَّافِي لَا شِفَاءَ إِلَّا شِفَاؤُكَ شِفَاءً لَا يُغَادِرُ سَقَمًا',
              'textFr':
                  'Ô Allah, Seigneur des hommes, dissipe le mal, guéris car Tu es le Guérisseur, il n\'y a de guérison que Ta guérison, une guérison qui ne laisse aucune maladie',
              'defaultReps': 7,
            },
            {
              'type': 'verses',
              'category': TaskCategory.healing,
              'surah': 1, // Al-Fatiha
              'ayahStart': 1,
              'ayahEnd': 7,
              'defaultReps': 7,
              'notesFr': 'Al-Fatiha est une guérison',
            },
            {
              'type': 'text',
              'category': TaskCategory.protection,
              'textAr':
                  'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
              'textFr': 'Au nom d\'Allah, avec Son nom rien ne peut nuire',
              'defaultReps': 3,
            },
          ],
        },
      ],
    },
    {
      'id': 'theme_friday',
      'nameFr': 'Vendredi Béni',
      'nameAr': 'يوم الجمعة المبارك',
      'frequency': 'weekly',
      'routines': [
        {
          'id': 'routine_friday',
          'nameFr': 'Routine du vendredi',
          'nameAr': 'أذكار الجمعة',
          'tasks': [
            {
              'type': 'verses',
              'category': TaskCategory.guidance,
              'surah': 18, // Al-Kahf
              'ayahStart': 1,
              'ayahEnd': 10,
              'defaultReps': 1,
              'notesFr':
                  'Les 10 premiers versets d\'Al-Kahf - Protection contre le Dajjal',
            },
            {
              'type': 'text',
              'category': TaskCategory.louange,
              'textAr': 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
              'textFr': 'Ô Allah, prie et salue notre Prophète Muhammad',
              'defaultReps': 100,
              'notesFr': 'Multiplier les prières sur le Prophète ﷺ le vendredi',
            },
          ],
        },
      ],
    },
  ];

  /// Invocations individuelles populaires (hors routines)
  static final standaloneInvocations = [
    {
      'id': 'inv_istighfar',
      'nameFr': 'Demande de pardon',
      'nameAr': 'الاستغفار',
      'category': TaskCategory.pardon,
      'textAr':
          'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
      'textFr':
          'Je demande pardon à Allah l\'Immense, il n\'y a de divinité que Lui, le Vivant, le Subsistant, et je me repens à Lui',
      'defaultReps': 100,
    },
    {
      'id': 'inv_salawat',
      'nameFr': 'Prière sur le Prophète',
      'nameAr': 'الصلاة على النبي',
      'category': TaskCategory.louange,
      'textAr':
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
      'textFr':
          'Ô Allah, prie sur Muhammad et la famille de Muhammad comme Tu as prié sur Ibrahim et la famille d\'Ibrahim, Tu es certes Digne de louange et de glorification',
      'defaultReps': 10,
    },
    {
      'id': 'inv_hasbunallah',
      'nameFr': 'Allah nous suffit',
      'nameAr': 'حسبنا الله',
      'category': TaskCategory.protection,
      'textAr': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'textFr': 'Allah nous suffit et quel excellent Protecteur',
      'defaultReps': 70,
      'notesFr': 'Dans les difficultés et les épreuves',
    },
  ];
}
