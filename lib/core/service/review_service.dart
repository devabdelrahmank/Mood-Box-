import 'dart:math';
import 'package:movie_proj/core/model/review_model.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  // قائمة أسماء المستخدمين
  final List<String> _usernames = [
    'MovieLover2024', 'CinemaFan', 'FilmCritic', 'ActionHero', 'DramaQueen',
    'SciFiGeek', 'HorrorFan', 'ComedyKing', 'ThrillerSeeker', 'RomanceFan',
    'AnimationLover', 'DocumentaryWatcher', 'IndieFilmFan', 'BlockbusterBuff',
    'ClassicCinema', 'ModernMovies', 'FilmStudent', 'CinephileLife',
    'MovieNight', 'ScreenTime', 'ReelTalk', 'FilmReview', 'CinemaScope',
    'MovieMagic', 'FilmBuff', 'CinemaAddict', 'MovieMarathon', 'FilmFanatic',
    'CinemaLover', 'MovieCritic', 'FilmExpert', 'CinemaGuru', 'MovieMaster',
    'FilmWatcher', 'CinemaExplorer', 'MovieDiscovery', 'FilmJourney',
    'CinemaQuest', 'MovieAdventure', 'FilmExperience', 'CinemaStory',
    'MovieTales', 'FilmNarrative', 'CinemaChronicle', 'MovieSaga',
    'FilmEpic', 'CinemaLegend', 'MovieClassic', 'FilmIcon'
  ];

  // قائمة التعليقات الإيجابية
  final List<String> _positiveReviews = [
    "Absolutely stunning! This movie exceeded all my expectations. The cinematography is breathtaking and the story is compelling from start to finish.",
    "One of the best films I've seen this year. The acting is superb and the direction is flawless. Highly recommended!",
    "A masterpiece of cinema! Every frame is beautifully crafted and the emotional depth is incredible.",
    "Brilliant storytelling with outstanding performances. This movie will stay with you long after the credits roll.",
    "Visually spectacular and emotionally powerful. The perfect blend of entertainment and artistry.",
    "An incredible journey that captivates from the first scene. The character development is exceptional.",
    "This film is a work of art. The attention to detail and the powerful narrative make it unforgettable.",
    "Outstanding in every aspect - acting, directing, cinematography, and soundtrack. A true cinematic gem.",
    "A phenomenal movie that delivers on all fronts. The story is engaging and the visuals are stunning.",
    "Exceptional filmmaking at its finest. This movie sets a new standard for the genre.",
    "Breathtaking visuals combined with a compelling story. This is cinema at its best.",
    "A remarkable achievement in filmmaking. The performances are outstanding and the story is captivating.",
    "This movie is pure magic. Every element comes together perfectly to create an unforgettable experience.",
    "Incredible storytelling with amazing character development. A must-watch for any movie lover.",
    "A cinematic masterpiece that showcases the power of great filmmaking. Absolutely brilliant!",
    "Outstanding performances and beautiful cinematography make this a truly special film.",
    "This movie is a perfect example of how cinema can move and inspire. Highly recommended!",
    "Exceptional direction and superb acting create a movie that's both entertaining and meaningful.",
    "A stunning visual feast with a heart-warming story. This film is a true work of art.",
    "Brilliant in every way. The story, acting, and visuals all come together to create something special."
  ];

  // قائمة التعليقات المتوسطة
  final List<String> _neutralReviews = [
    "A decent movie with some good moments. The story is interesting but could have been developed better.",
    "Good entertainment value with solid performances. Not groundbreaking but enjoyable to watch.",
    "The movie has its strengths and weaknesses. Some parts are excellent while others feel rushed.",
    "A solid film that delivers what it promises. Good acting and decent story, though not exceptional.",
    "Entertaining enough for a movie night. The visuals are good but the story is somewhat predictable.",
    "A watchable film with some memorable scenes. The pacing could be better but overall it's okay.",
    "Good production values and decent acting. The story is familiar but well-executed.",
    "An average movie that doesn't disappoint but doesn't excel either. Worth watching once.",
    "The film has good moments but lacks consistency. Some scenes are brilliant while others fall flat.",
    "Decent entertainment with good technical aspects. The story could have been more engaging.",
    "A competent film that does what it sets out to do. Not amazing but not bad either.",
    "Good cinematography and acting save an otherwise ordinary story. Worth a watch.",
    "The movie is well-made but doesn't bring anything new to the table. Still enjoyable.",
    "Solid performances and good direction make up for a somewhat weak script.",
    "An okay film that has its moments. The ending is satisfying but the journey is uneven.",
    "Good production quality and decent story. Not memorable but entertaining enough.",
    "The movie delivers on its promises but doesn't exceed expectations. A safe choice.",
    "Well-acted and nicely shot, but the story feels familiar. Still worth watching.",
    "A competent effort with good technical aspects. The story could be more original.",
    "Decent entertainment value with some good performances. Not bad but not great either."
  ];

  // قائمة التعليقات السلبية
  final List<String> _negativeReviews = [
    "Disappointing overall. The story lacks depth and the pacing is off. Expected much more.",
    "Not impressed with this one. The plot is confusing and the characters are underdeveloped.",
    "The movie tries too hard but fails to deliver. Weak story and poor execution.",
    "Boring and predictable. The film doesn't bring anything new and feels like a waste of time.",
    "Poor storytelling and weak character development. The movie fails to engage the audience.",
    "Overhyped and underwhelming. The story is shallow and the acting is mediocre at best.",
    "A mess of a movie with no clear direction. The plot is all over the place.",
    "Disappointing considering the potential. The execution doesn't match the concept.",
    "Weak script and poor direction make this a forgettable experience. Not recommended.",
    "The movie lacks substance and feels rushed. Many plot holes and inconsistencies.",
    "Boring and unoriginal. The film doesn't offer anything new or interesting.",
    "Poor pacing and weak character development ruin what could have been a good story.",
    "The movie is all style and no substance. Looks good but lacks emotional depth.",
    "Disappointing performances and a confusing plot make this hard to recommend.",
    "The film tries to be too many things and succeeds at none. A confused mess.",
    "Weak storytelling and poor execution make this a forgettable movie.",
    "The movie lacks focus and direction. The story is all over the place.",
    "Disappointing considering the talent involved. The script lets everyone down.",
    "Boring and predictable with no surprises. A waste of good actors.",
    "The movie fails to deliver on its promises. Weak story and poor direction."
  ];

  // قائمة التواريخ
  final List<String> _dates = [
    '15 Jan 2024', '22 Jan 2024', '03 Feb 2024', '14 Feb 2024', '28 Feb 2024',
    '05 Mar 2024', '18 Mar 2024', '25 Mar 2024', '02 Apr 2024', '15 Apr 2024',
    '28 Apr 2024', '05 May 2024', '18 May 2024', '25 May 2024', '02 Jun 2024',
    '15 Jun 2024', '28 Jun 2024', '05 Jul 2024', '18 Jul 2024', '25 Jul 2024',
    '02 Aug 2024', '15 Aug 2024', '28 Aug 2024', '05 Sep 2024', '18 Sep 2024',
    '25 Sep 2024', '02 Oct 2024', '15 Oct 2024', '28 Oct 2024', '05 Nov 2024',
    '18 Nov 2024', '25 Nov 2024', '02 Dec 2024', '15 Dec 2024', '28 Dec 2024'
  ];

  List<ReviewModel> generateRandomReviews({int count = 100}) {
    final Random random = Random();
    final List<ReviewModel> reviews = [];

    for (int i = 0; i < count; i++) {
      // اختيار نوع التعليق بناءً على التقييم
      final double rating = _generateRandomRating(random);
      final String content = _getReviewContentByRating(rating, random);
      
      reviews.add(ReviewModel(
        id: 'review_${i + 1}',
        username: _usernames[random.nextInt(_usernames.length)],
        content: content,
        rating: rating,
        date: _dates[random.nextInt(_dates.length)],
        helpfulCount: random.nextInt(500) + 10,
        notHelpfulCount: random.nextInt(100) + 1,
      ));
    }

    return reviews;
  }

  double _generateRandomRating(Random random) {
    // توزيع التقييمات: 40% عالي (8-10), 40% متوسط (6-7.9), 20% منخفض (1-5.9)
    final int category = random.nextInt(10);
    
    if (category < 4) {
      // تقييم عالي (8.0 - 10.0)
      return 8.0 + (random.nextDouble() * 2.0);
    } else if (category < 8) {
      // تقييم متوسط (6.0 - 7.9)
      return 6.0 + (random.nextDouble() * 1.9);
    } else {
      // تقييم منخفض (1.0 - 5.9)
      return 1.0 + (random.nextDouble() * 4.9);
    }
  }

  String _getReviewContentByRating(double rating, Random random) {
    if (rating >= 8.0) {
      return _positiveReviews[random.nextInt(_positiveReviews.length)];
    } else if (rating >= 6.0) {
      return _neutralReviews[random.nextInt(_neutralReviews.length)];
    } else {
      return _negativeReviews[random.nextInt(_negativeReviews.length)];
    }
  }

  List<ReviewModel> getRandomReviews({int count = 2}) {
    final allReviews = generateRandomReviews();
    final Random random = Random();
    
    // خلط القائمة واختيار عدد محدد
    allReviews.shuffle(random);
    return allReviews.take(count).toList();
  }
}
