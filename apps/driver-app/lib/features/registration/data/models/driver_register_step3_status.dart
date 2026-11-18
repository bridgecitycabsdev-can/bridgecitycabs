enum DriverRegisterStep3Status {
  initial,
  uploading,
  uploadModal,
  actionRequired,
  ready,
  submitting,
  success;

  bool get isInitial => this == DriverRegisterStep3Status.initial;
  bool get isUploading => this == DriverRegisterStep3Status.uploading;
  bool get isUploadModal => this == DriverRegisterStep3Status.uploadModal;
  bool get isActionRequired => this == DriverRegisterStep3Status.actionRequired;
  bool get isReady => this == DriverRegisterStep3Status.ready;
  bool get isSubmitting => this == DriverRegisterStep3Status.submitting;
  bool get isSuccess => this == DriverRegisterStep3Status.success;
}
