import 'package:blogin/openning/OTP-code/OTP_confirmation.dart';
import 'package:blogin/openning/OTP-code/OTP_form.dart';
import 'package:blogin/openning/signin-form/signin-form.dart';
import 'package:blogin/openning/password-change/password-change.dart';
import 'package:blogin/openning/sign-up-form/signup_form.dart';
import 'package:blogin/openning/splash-screen/splash-screen.dart';
import 'package:blogin/openning/user-nickname/name_form.dart';
import 'package:blogin/openning/user-nickname/name_form_done_splash.dart';
import 'package:blogin/pages/blog/category_page.dart';
import 'package:blogin/pages/main%20page/main_page.dart';
import 'package:blogin/pages/profile/profile_page.dart';
import 'package:blogin/pages/profile/edit_profile.dart';
import 'package:blogin/pages/profile/edit_profile_done_splash.dart';
import 'package:blogin/pages/library/library_page.dart';
import 'package:blogin/pages/search%20page/search_page.dart';
import 'package:blogin/pages/blog/blog_maker.dart';
import 'package:flutter/material.dart';
import 'package:blogin/services/local_backend_service.dart';
import 'package:blogin/routes/not_found.dart';
import 'package:blogin/pages/blog/content_page.dart';
import 'package:blogin/openning/password-change/email_input.dart';
import 'package:blogin/services/hive_backend.dart';
import 'package:blogin/pages/blog/publish_option.dart';
import 'package:blogin/pages/profile/logout_done.dart';
import 'package:blogin/pages/blog/blog_done.dart';

// Route Names
const String splashRoute = '/splash';
const String signUpRoute = '/signup';
const String signInRoute = '/signin';
const String newPasswordRoute = '/new-password';
const String otpRoute = '/otp';
const String otpConfirmationRoute = '/otp-confirmation';
const String nameRoute = '/name';
const String nameFormDoneSplashRoute = '/name-done-splash';
const String mainPageRoute = '/main-page';
const String containPageRoute = '/contain-page';
const String containExampleRoute = '/contain-example';
const String containExample2Route = '/contain-example2';
const String containExample3Route = '/contain-example3';
const String containExample4Route = '/contain-example4';
const String containExample5Route = '/contain-example5';
const String profilePageRoute = '/profile-page';
const String libraryPageRoute = '/library-page';
const String searchPageRoute = '/search-page';
const String editProfileRoute = '/edit-profile';
const String editProfileDoneSplashRoute = '/edit-profile-done-splash';
const String blogMakerRoute = '/blog-maker';
const String notFoundRoute = '/';
const String contentPageRoute = '/content-page';
const String emailInputRoute = '/email-input';
const String categoryPageRoute = '/category-page';
const String publishOptionRoute = '/publish-option';
const String logoutDoneSplashRoute = '/logout-done-splash';
const String blogDoneSplashRoute = '/blog-done-splash';
// Add other routes here as needed

// Route Generator
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case splashRoute:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case otpConfirmationRoute:
      final String email =
          settings.arguments as String? ??
          LocalBackendService.instance.getEmail();
      return MaterialPageRoute(
        builder: (_) => VerifyCodeConfirmation(email: email),
      );
    case signUpRoute:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    case signInRoute:
      return MaterialPageRoute(builder: (_) => const SignInScreen());
    case newPasswordRoute:
      return MaterialPageRoute(builder: (_) => const NewPasswordScreen());
    case otpRoute:
      final String email =
          settings.arguments as String? ??
          LocalBackendService.instance.getEmail();
      return MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: email));
    case nameRoute:
      return MaterialPageRoute(builder: (_) => const UserDataForm());
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
    case editProfileDoneSplashRoute:
      return MaterialPageRoute(
        builder: (_) => const EditProfileDoneSplashScreen(),
      );
    case blogMakerRoute:
      return MaterialPageRoute(builder: (_) => const BlogMakerPage());
    case contentPageRoute:
      final String blogId = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => ContentPage(blogId: blogId));
    case emailInputRoute:
      return MaterialPageRoute(builder: (_) => const EmailInputPage());
    //make a route for the category page
    case categoryPageRoute:
      final BlogPost blogPost =
          settings.arguments as BlogPost; //fixing the error
      return MaterialPageRoute(
        builder: (_) => CategoryPage(blogPost: blogPost),
      );
    case publishOptionRoute:
      final BlogPost blogPost =
          settings.arguments as BlogPost; //fixing the error
      return MaterialPageRoute(
        builder: (_) => PublishOptionPage(blogPost: blogPost),
      ); //fi
    case logoutDoneSplashRoute:
      return MaterialPageRoute(builder: (_) => const LogoutDoneSplashScreen());
    case blogDoneSplashRoute:
      return MaterialPageRoute(builder: (_) => const BlogDoneSplashScreen());
    // Default case for unknown routes
    default:
      return MaterialPageRoute(builder: (_) => const NotFoundPage());
  }
}
