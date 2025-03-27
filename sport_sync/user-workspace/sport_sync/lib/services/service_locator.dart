import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'wearable_service.dart';
import 'ai_service.dart';
import 'payment_service.dart';
import '../utils/constants.dart';

class ServiceLocator {
  // Private constructor to prevent instantiation
  ServiceLocator._();

  // Factory method to create all providers
  static List<ChangeNotifierProvider> createProviders() {
    return [
      ChangeNotifierProvider<AuthService>(
        create: (_) => AuthService(),
      ),
      ChangeNotifierProvider<FirebaseService>(
        create: (_) => FirebaseService(),
      ),
      ChangeNotifierProvider<WearableService>(
        create: (_) => WearableService(
          apiKey: AppConstants.wearableApiKey,
        ),
      ),
      ChangeNotifierProvider<AIService>(
        create: (_) => AIService(
          apiKey: AppConstants.aiApiKey,
        ),
      ),
      ChangeNotifierProvider<PaymentService>(
        create: (_) => PaymentService(
          apiKey: AppConstants.paymentApiKey,
          provider: PaymentProvider.stripe,
        ),
      ),
    ];
  }

  // Helper methods to access services
  static AuthService getAuthService(BuildContext context) {
    return Provider.of<AuthService>(context, listen: false);
  }

  static FirebaseService getFirebaseService(BuildContext context) {
    return Provider.of<FirebaseService>(context, listen: false);
  }

  static WearableService getWearableService(BuildContext context) {
    return Provider.of<WearableService>(context, listen: false);
  }

  static AIService getAIService(BuildContext context) {
    return Provider.of<AIService>(context, listen: false);
  }

  static PaymentService getPaymentService(BuildContext context) {
    return Provider.of<PaymentService>(context, listen: false);
  }

  // Initialize all services
  static Future<void> initializeServices() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Initialize other services that require async initialization
      // Add any other service initialization here
      
    } catch (e) {
      print('Error initializing services: $e');
      rethrow;
    }
  }

  // Dispose all services
  static void disposeServices(BuildContext context) {
    try {
      getWearableService(context).dispose();
      getAIService(context).dispose();
      getPaymentService(context).dispose();
    } catch (e) {
      print('Error disposing services: $e');
    }
  }
}

// Extension methods for easier service access
extension ServiceLocatorExtension on BuildContext {
  AuthService get authService => ServiceLocator.getAuthService(this);
  FirebaseService get firebaseService => ServiceLocator.getFirebaseService(this);
  WearableService get wearableService => ServiceLocator.getWearableService(this);
  AIService get aiService => ServiceLocator.getAIService(this);
  PaymentService get paymentService => ServiceLocator.getPaymentService(this);
}

// Mixin for service access in widgets
mixin ServiceAccessMixin<T extends StatefulWidget> on State<T> {
  AuthService get authService => context.authService;
  FirebaseService get firebaseService => context.firebaseService;
  WearableService get wearableService => context.wearableService;
  AIService get aiService => context.aiService;
  PaymentService get paymentService => context.paymentService;

  @override
  void dispose() {
    ServiceLocator.disposeServices(context);
    super.dispose();
  }
}

// Provider wrapper widget
class ServiceProvider extends StatelessWidget {
  final Widget child;

  const ServiceProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ServiceLocator.createProviders(),
      child: child,
    );
  }
}

// Service initialization widget
class ServiceInitializer extends StatelessWidget {
  final Widget child;

  const ServiceInitializer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ServiceLocator.initializeServices(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing services: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ServiceProvider(child: child);
        }

        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}