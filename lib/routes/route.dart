import 'package:flutter/material.dart';
import 'package:blogin/openning/splash-screen/splash-screen.dart';
import 'package:blogin/openning/sign-up-form/signup_form.dart';
import 'package:blogin/openning/signin-form/signin-form.dart';
import 'package:blogin/openning/user-nickname/name_form_done_splash.dart';
import 'package:blogin/pages/main page/main_page.dart';
import 'package:blogin/pages/profile/profile_page.dart';
import 'package:blogin/pages/profile/edit_profile.dart';
import 'package:blogin/pages/library/library_page.dart';
import 'package:blogin/pages/search page/search_page.dart';
import 'package:blogin/pages/blog/blog_maker.dart';
import 'package:blogin/pages/blog/category_page.dart';
import 'package:blogin/pages/blog/publish_option.dart';
import 'package:blogin/pages/blog/blog_done.dart';
import 'package:blogin/services/hive_backend.dart';

// Route names
const String splashRoute = '/';
const String signUpRoute = '/signup';
const String signInRoute = '/signin';
const String nameFormDoneSplashRoute = '/name-form-done';
const String mainPageRoute = '/main';
const String profilePageRoute = '/profile';
const String editProfileRoute = '/edit-profile';
const String libraryPageRoute = '/library';
const String searchPageRoute = '/search';
const String blogMakerRoute = '/blog-maker';
const String categoryPageRoute = '/category';
const String publishOptionRoute = '/publish-option';
const String blogDoneSplashRoute = '/blog-done';
// const String emailInputRoute = '/email-input';
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case splashRoute:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case signUpRoute:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    case signInRoute:
      return MaterialPageRoute(builder: (_) => const SignInScreen());
    // case emailInputRoute:
    //   return MaterialPageRoute(builder: (_) => const EmailInputPage());
    case nameFormDoneSplashRoute:
      return MaterialPageRoute(
        builder: (_) => const NameFormDoneSplashScreen(),
      );
    case mainPageRoute:
      return MaterialPageRoute(builder: (_) => const MainPage());
    case profilePageRoute:
      return MaterialPageRoute(builder: (_) => const ProfilePage());
    case libraryPageRoute:
      return MaterialPageRoute(builder: (_) => const LibraryPage());
    case searchPageRoute:
      return MaterialPageRoute(builder: (_) => const SearchPage());
    case editProfileRoute:
      return MaterialPageRoute(builder: (_) => const EditProfilePage());
    case blogMakerRoute:
      return MaterialPageRoute(builder: (_) => const BlogMakerPage());
    case categoryPageRoute:
      final BlogPost blogPost = settings.arguments as BlogPost;
      return MaterialPageRoute(
        builder: (_) => CategoryPage(blogPost: blogPost),
      );
    case publishOptionRoute:
      final BlogPost blogPost = settings.arguments as BlogPost;
      return MaterialPageRoute(
        builder: (_) => PublishOptionPage(blogPost: blogPost),
      );
    case blogDoneSplashRoute:
      return MaterialPageRoute(builder: (_) => const BlogDoneSplashScreen());
    default:
      return MaterialPageRoute(
        builder:
            (_) => Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            ),
      );
  }
}
