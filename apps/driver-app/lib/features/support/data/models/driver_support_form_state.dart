enum DriverSupportFormInspectorState {
  ready,
  empty,
  sending,
  error;

  String get label {
    switch (this) {
      case DriverSupportFormInspectorState.ready:
        return 'Ready';
      case DriverSupportFormInspectorState.empty:
        return 'Empty';
      case DriverSupportFormInspectorState.sending:
        return 'Sending';
      case DriverSupportFormInspectorState.error:
        return 'Error';
    }
  }

  bool get isReady => this == DriverSupportFormInspectorState.ready;
  bool get isEmpty => this == DriverSupportFormInspectorState.empty;
  bool get isSending => this == DriverSupportFormInspectorState.sending;
  bool get isError => this == DriverSupportFormInspectorState.error;
}

enum DriverSupportDispatchState {
  active,
  empty,
  loading,
  error;

  String get label {
    switch (this) {
      case DriverSupportDispatchState.active:
        return 'Active';
      case DriverSupportDispatchState.empty:
        return 'Empty';
      case DriverSupportDispatchState.loading:
        return 'Loading';
      case DriverSupportDispatchState.error:
        return 'Error';
    }
  }

  bool get isActive => this == DriverSupportDispatchState.active;
  bool get isEmpty => this == DriverSupportDispatchState.empty;
  bool get isLoading => this == DriverSupportDispatchState.loading;
  bool get isError => this == DriverSupportDispatchState.error;
}
