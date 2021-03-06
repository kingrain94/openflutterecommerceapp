import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:openflutterecommerce/config/routes.dart';
import 'package:openflutterecommerce/config/theme.dart';
import 'package:openflutterecommerce/data/abstract/product_repository.dart';
import 'package:openflutterecommerce/data/fake_model/fake_product_repository.dart';
import 'package:openflutterecommerce/presentation/features/product_details/product_screen.dart';
import 'package:openflutterecommerce/presentation/features/products/products.dart';
import 'package:openflutterecommerce/presentation/features/splash_screen.dart';

import 'config/routes.dart';
import 'data/abstract/category_repository.dart';
import 'data/fake_model/fake_category_repository.dart';
import 'presentation/features/authentication/authentication.dart';
import 'presentation/features/cart/cart.dart';
import 'presentation/features/categories/categories.dart';
import 'presentation/features/checkout/checkout.dart';
import 'presentation/features/favorites/favorites.dart';
import 'presentation/features/home/home.dart';
import 'presentation/features/profile/profile.dart';
import 'presentation/features/signin/forget_password.dart';
import 'presentation/features/signin/signin.dart';
import 'presentation/features/signin/signup.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() async {
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_US',
    supportedLocales: ['en_US', 'de', 'fr'],
  );

  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) => AuthenticationBloc()..add(AppStarted()),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<CategoryRepository>(
            create: (context) => FakeCategoryRepository(),
          ),
          RepositoryProvider<ProductRepository>(
            create: (context) => FakeProductRepository(),
          ),
        ],
        child: LocalizedApp(
          delegate,
          OpenFlutterEcommerceApp(),
        ),
      ),
    ),
  );
}

class OpenFlutterEcommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
        state: LocalizationProvider.of(context).state,
        child: MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            localizationDelegate,
          ],
          onGenerateRoute: _registerRoutesWithParameters,
          supportedLocales: localizationDelegate.supportedLocales,
          debugShowCheckedModeBanner: false,
          locale: localizationDelegate.currentLocale,
          title: 'Open FLutter E-commerce',
          theme: OpenFlutterEcommerceTheme.of(context),
          routes: _registerRoutes(),
        ));
  }

  Map<String, WidgetBuilder> _registerRoutes() {
    return <String, WidgetBuilder>{
      OpenFlutterEcommerceRoutes.home: (context) => HomeScreen(),
      OpenFlutterEcommerceRoutes.cart: (context) => CartScreen(),
      OpenFlutterEcommerceRoutes.checkout: (context) => CheckoutScreen(),
      OpenFlutterEcommerceRoutes.favourites: (context) => FavouriteScreen(),
      OpenFlutterEcommerceRoutes.signin: (context) => _buildSignInBloc(),
      OpenFlutterEcommerceRoutes.signup: (context) => _buildSignUpBloc(),
      OpenFlutterEcommerceRoutes.forgotPassword: (context) =>
          _buildForgetPasswordBloc(),
      OpenFlutterEcommerceRoutes.profile: (context) =>
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
            if (state is Authenticated) {
              return ProfileScreen(); //TODO profile properties should be here
            } else if (state is Unauthenticated) {
              return _buildSignInBloc();
            } else {
              return SplashScreen();
            }
          }),
    };
  }

  BlocProvider<ForgetPasswordBloc> _buildForgetPasswordBloc() {
    return BlocProvider<ForgetPasswordBloc>(
      create: (context) => ForgetPasswordBloc(),
      child: ForgetPasswordScreen(),
    );
  }

  BlocProvider<SignInBloc> _buildSignInBloc() {
    return BlocProvider<SignInBloc>(
      create: (context) => SignInBloc(),
      child: SignInScreen(),
    );
  }

  BlocProvider<SignUpBloc> _buildSignUpBloc() {
    return BlocProvider<SignUpBloc>(
      create: (context) => SignUpBloc(),
      child: SignUpScreen(),
    );
  }

  Route _registerRoutesWithParameters(RouteSettings settings) {
    if (settings.name == OpenFlutterEcommerceRoutes.shop) {
      final CategoriesParameters args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          return CategoriesScreen(
            parameters: args,
          );
        },
      );
    } else if (settings.name == OpenFlutterEcommerceRoutes.productList) {
      final ProductListScreenParameters productListScreenParameters =
          settings.arguments;
      return MaterialPageRoute(builder: (context) {
        return ProductsScreen(
          parameters: productListScreenParameters,
        );
      });
    } else if (settings.name == OpenFlutterEcommerceRoutes.product) {
      final ProductDetailsParameters parameters = settings.arguments;
      return MaterialPageRoute(builder: (context) {
        return ProductDetailsScreen(parameters);
      });
    } else {
      return MaterialPageRoute(
        builder: (context) {
          return HomeScreen();
        },
      );
    }
  }
}
