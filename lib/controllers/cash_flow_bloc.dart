import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart'; // Professional state comparison ke liye
import '../services/image_scanner_service.dart';

// --- States ---
abstract class CashFlowState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CashFlowInitial extends CashFlowState {}
class CashFlowLoading extends CashFlowState {}

class CashFlowLoaded extends CashFlowState {
  final String amount;
  CashFlowLoaded(this.amount);

  @override
  List<Object?> get props => [amount]; // Sirf tab update karo jab amount badle
}

class CashFlowError extends CashFlowState {
  final String message;
  CashFlowError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Events ---
abstract class CashFlowEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartScanning extends CashFlowEvent {}

// --- Bloc Layer ---
class CashFlowBloc extends Bloc<CashFlowEvent, CashFlowState> {
  final ImageScannerService _scanner = ImageScannerService();

  CashFlowBloc() : super(CashFlowInitial()) {
    on<StartScanning>((event, emit) async {
      emit(CashFlowLoading()); // Dashboard par spinner dikhao
      
      try {
        final result = await _scanner.scanBillAndGetAmount(); // Scanner call kiya
        
        if (result != null && result != "0.00") {
          emit(CashFlowLoaded(result)); // Amount mil gayi
        } else {
          emit(CashFlowError("Could not detect amount. Please try again."));
        }
      } catch (e) {
        emit(CashFlowError("System Error: ${e.toString()}"));
      }
    });
  }
}