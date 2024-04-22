
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/routes.gr.dart';

const authRoutes = [
  AutoRoute(
    path: '/login',
    page: LoginScreen,
    children: [
      RedirectRoute(path: '*', redirectTo: ''),
    ],
  ),

  AutoRoute(
    path: '/verify-email',
    page: EmailVerifyScreen,
  ),
];

const googleClientId = '582214367176-tbs5t9ebp84fvmrieirce557lv0cfmn5.apps.googleusercontent.com';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    bool loggedIn = FirebaseAuth.instance.currentUser != null;
    if (loggedIn) return resolver.next(true);
    router.push(const LoginScreenRoute());
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SignInScreen(
        actions: [
          ForgotPasswordAction((context, email) {
            Navigator.pushNamed(
              context,
              '/forgot-password',
              arguments: {'email': email},
            );
          }),
          VerifyPhoneAction((context, _) {
            Navigator.pushNamed(context, '/phone');
          }),
          AuthStateChangeAction<SignedIn>((context, state) {
            if (!state.user!.emailVerified) {
              AutoRouter.of(context).push(const EmailVerifyScreenRoute());
            } else {
              AutoRouter.of(context).pushAndPopUntil(OverviewScreenRoute(), predicate: (r) => false);
            }
          }),
          AuthStateChangeAction<UserCreated>((context, state) {
            if (!state.credential.user!.emailVerified) {
              AutoRouter.of(context).push(const EmailVerifyScreenRoute());
            } else {
              AutoRouter.of(context).push(OverviewScreenRoute());
            }
          }),
          EmailLinkSignInAction((context) {
            Navigator.pushReplacementNamed(context, '/email-link-sign-in');
          }),
        ],
      ),
    );
  }
}

class EmailVerifyScreen extends StatelessWidget {
  const EmailVerifyScreen();

  @override
  Widget build(BuildContext context) {
    return EmailVerificationScreen(
      actionCodeSettings: ActionCodeSettings(
        url: 'https://app.bloomcyclecare.com',
        handleCodeInApp: true,
      ),
      actions: [
        EmailVerifiedAction(() {
          AutoRouter.of(context).push(OverviewScreenRoute());
        }),
        AuthCancelledAction((context) {
          FirebaseUIAuth.signOut(context: context);
          AutoRouter.of(context).push(const LoginScreenRoute());
        }),
      ],
    );
  }
}
