import 'package:equatable/equatable.dart';
import '../../data/models/add_card_models.dart';

class AddCardState extends Equatable {
  final AddCardStatus status;
  final CardFormData form;
  final ThreeDSecureData threeD;
  final String? errorMessage;
  final bool showBankConfirmDialog;
  final bool showThreeDDialog;
  final bool navigateToPaymentMethods;

  const AddCardState({
    this.status = AddCardStatus.initial,
    this.form = const CardFormData(),
    this.threeD = const ThreeDSecureData(),
    this.errorMessage,
    this.showBankConfirmDialog = false,
    this.showThreeDDialog = false,
    this.navigateToPaymentMethods = false,
  });

  bool get isInitial => status == AddCardStatus.initial;
  bool get isTokenizing => status == AddCardStatus.tokenizing;
  bool get isConfirmingBank => status == AddCardStatus.confirmingBank;
  bool get is3DSecure => status == AddCardStatus.threeDSecureOtp;
  bool get isSuccess => status == AddCardStatus.success;
  bool get isDeclined => status == AddCardStatus.declined;
  bool get isVerificationPending => status == AddCardStatus.verificationPending;

  bool get canSave => form.isFormValid && !isTokenizing;

  AddCardState copyWith({
    AddCardStatus? status,
    CardFormData? form,
    ThreeDSecureData? threeD,
    String? errorMessage,
    bool clearError = false,
    bool? showBankConfirmDialog,
    bool? showThreeDDialog,
    bool? navigateToPaymentMethods,
  }) {
    return AddCardState(
      status: status ?? this.status,
      form: form ?? this.form,
      threeD: threeD ?? this.threeD,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      showBankConfirmDialog:
          showBankConfirmDialog ?? this.showBankConfirmDialog,
      showThreeDDialog: showThreeDDialog ?? this.showThreeDDialog,
      navigateToPaymentMethods:
          navigateToPaymentMethods ?? this.navigateToPaymentMethods,
    );
  }

  @override
  List<Object?> get props => [
        status,
        form,
        threeD,
        errorMessage,
        showBankConfirmDialog,
        showThreeDDialog,
        navigateToPaymentMethods,
      ];
}
