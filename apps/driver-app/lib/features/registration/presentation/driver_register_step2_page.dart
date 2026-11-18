import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/driver_register_step2_bloc.dart';
import '../bloc/driver_register_step2_event.dart';
import '../bloc/driver_register_step2_state.dart';
import '../data/models/driver_register_config.dart';
import '../data/models/driver_register_step2_status.dart';
import '../data/models/driver_vehicle_class.dart';
import 'widgets/driver_register_step2_progress_indicator.dart';
import 'widgets/driver_register_step2_qa_matrix_bar.dart';
import 'widgets/driver_vehicle_class_selector.dart';
import 'widgets/driver_vehicle_dispatch_toggles.dart';
import 'widgets/driver_vehicle_plate_card.dart';
import 'widgets/driver_vehicle_year_modal.dart';

class DriverRegisterStep2Page extends StatelessWidget {
  final DriverRegisterStep2Status initialStatus;

  const DriverRegisterStep2Page({
    super.key,
    this.initialStatus = DriverRegisterStep2Status.initial,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverRegisterStep2Bloc()
        ..add(DriverRegisterStep2Started(initialStatus: initialStatus)),
      child: const _DriverRegisterStep2View(),
    );
  }
}

class _DriverRegisterStep2View extends StatefulWidget {
  const _DriverRegisterStep2View();

  @override
  State<_DriverRegisterStep2View> createState() =>
      _DriverRegisterStep2ViewState();
}

class _DriverRegisterStep2ViewState extends State<_DriverRegisterStep2View> {
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _colourController;
  late final TextEditingController _plateController;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<DriverRegisterStep2Bloc>();
    _makeController = TextEditingController(text: bloc.state.data.make);
    _modelController = TextEditingController(text: bloc.state.data.model);
    _colourController = TextEditingController(text: bloc.state.data.colour);
    _plateController = TextEditingController(text: bloc.state.data.plateNumber);
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _colourController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _syncControllers(DriverRegisterStep2State state) {
    if (_makeController.text != state.data.make) {
      _makeController.text = state.data.make;
    }
    if (_modelController.text != state.data.model) {
      _modelController.text = state.data.model;
    }
    if (_colourController.text != state.data.colour) {
      _colourController.text = state.data.colour;
    }
    if (_plateController.text != state.data.plateNumber) {
      _plateController.text = state.data.plateNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverRegisterStep2Bloc, DriverRegisterStep2State>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage ||
          prev.status != curr.status ||
          prev.data != curr.data,
      listener: (context, state) {
        _syncControllers(state);

        if (state.feedbackMessage != null && state.feedbackMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              backgroundColor: state.status == DriverRegisterStep2Status.success
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverRegisterStep2Bloc>();
        final isValid = state.status == DriverRegisterStep2Status.valid;
        final isInvalid = state.status == DriverRegisterStep2Status.invalid;
        final isInitial = state.status == DriverRegisterStep2Status.initial;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: const Text(
              'Your Vehicle',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF90141E),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // QA Matrix Bar for Screen Testing
                    DriverRegisterStep2QaMatrixBar(
                      currentStatus: state.status,
                      onStatusSelected: (status) {
                        bloc.add(DriverRegisterStep2StateSwitched(status));
                      },
                    ),
                    const SizedBox(height: 16),

                    // Progress Indicator (Step 2 of 4)
                    DriverRegisterStep2ProgressIndicator(status: state.status),
                    const SizedBox(height: 24),

                    // SECTION 1: VEHICLE CLASS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'VEHICLE CLASS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        if (isValid)
                          Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF2E7D32),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified for Fleet',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        else if (isInitial)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Required',
                              style: TextStyle(
                                color: Color(0xFFC62828),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3 Vehicle Class Cards
                    DriverVehicleClassSelector(
                      selectedClass: state.data.vehicleClass,
                      onClassSelected: (vehicleClass) {
                        bloc.add(
                            DriverRegisterVehicleClassSelected(vehicleClass));
                      },
                    ),
                    const SizedBox(height: 10),

                    // Vehicle Class Subtext Callout
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Color(0xFFC62828),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.data.vehicleClass?.description ??
                                  'Medium: Standard sedans and small SUVs for up to 4 passengers with carry-on luggage.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF4B5563),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // HERO VEHICLE BANNER (Approved badge)
                    if (isValid) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 130,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Text(
                                  'DRIVER\nREGISTER 2',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              Center(
                                child: Icon(
                                  Icons.directions_car_filled,
                                  size: 72,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'FLEET INSPECTION APPROVED',
                                    style: TextStyle(
                                      color: Color(0xFFC62828),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // SECTION 2: VEHICLE DETAILS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'VEHICLE DETAILS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        if (isValid)
                          Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF2E7D32),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'All fields confirmed',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Make Input Tile
                    _buildDetailInput(
                      label: 'VEHICLE MAKE',
                      hint: 'e.g. Toyota',
                      controller: _makeController,
                      icon: Icons.directions_car_outlined,
                      isValid: isValid,
                      onChanged: (val) => bloc.add(DriverRegisterMakeChanged(val)),
                    ),
                    const SizedBox(height: 12),

                    // Model & Powertrain Input Tile
                    _buildDetailInput(
                      label: 'MODEL & POWERTRAIN',
                      hint: 'e.g. Camry Hybrid',
                      controller: _modelController,
                      icon: Icons.electric_car_outlined,
                      isValid: isValid,
                      onChanged: (val) =>
                          bloc.add(DriverRegisterModelChanged(val)),
                    ),
                    const SizedBox(height: 12),

                    // Two-Column Row: Year & Colour
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Model Year Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                key: const ValueKey('driver_year_picker_trigger'),
                                onTap: () =>
                                    bloc.add(const DriverRegisterYearPickerOpened()),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: state.yearError != null
                                          ? const Color(0xFFD32F2F)
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'MODEL YEAR',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          if (isInvalid)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFEBEE),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Min. 2014 req.',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFC62828),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            state.data.year != null
                                                ? '${state.data.year}'
                                                : 'Year ⌄',
                                            key: const ValueKey('driver_selected_year_display'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: state.data.year != null
                                                  ? const Color(0xFF1F2937)
                                                  : const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                          if (isValid)
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFE8F5E9),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Color(0xFF2E7D32),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (state.yearError != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '⚠️ ${state.yearError}',
                                  key: const ValueKey('driver_year_error_text'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Exterior Colour Column
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'EXTERIOR COLOUR',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (isValid)
                                            const Text(
                                              '● ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                            ),
                                          Expanded(
                                            child: Text(
                                              state.data.colour.isNotEmpty
                                                  ? state.data.colour
                                                  : 'Colour ⌄',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    state.data.colour.isNotEmpty
                                                        ? const Color(
                                                            0xFF1F2937)
                                                        : const Color(
                                                            0xFF9CA3AF),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isValid)
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFE8F5E9),
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SECTION 3: LICENSE PLATE
                    DriverVehiclePlateCard(
                      plateNumber: state.data.plateNumber,
                      errorText: state.plateError,
                      isValid: isValid,
                      onChanged: (val) =>
                          bloc.add(DriverRegisterPlateChanged(val)),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 4: DISPATCH PREFERENCES
                    DriverVehicleDispatchToggles(
                      suitableForVanOnly: state.data.suitableForVanOnly,
                      femaleDriverOnly: state.data.femaleDriverOnly,
                      onVanOnlyChanged: (val) =>
                          bloc.add(DriverRegisterVanOnlyToggled(val)),
                      onFemaleDriverChanged: (val) =>
                          bloc.add(DriverRegisterFemaleDriverToggled(val)),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 5: REGULATORY / QUALITY STANDARDS CARD
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFEBEE),
                            ),
                            child: const Icon(
                              Icons.security,
                              color: Color(0xFFC62828),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isInvalid
                                      ? 'Lethbridge City Bylaw #5834'
                                      : 'Bridge City Cabs Quality Standards',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isInvalid
                                      ? 'Vehicles older than 10 years cannot be registered for taxi dispatch service in Lethbridge.'
                                      : 'Your vehicle must be in good condition, smoke-free, and pass semi-annual mechanical inspections per municipal guidelines.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.35,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ERROR ALERT (Invalid state)
                    if (isInvalid) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.error_outline,
                              color: Color(0xFFD32F2F),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '! Please correct the highlighted errors above',
                                key: ValueKey('driver_general_validation_alert'),
                                style: TextStyle(
                                  color: Color(0xFFD32F2F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // FOOTER LEGAL COMPLIANCE TEXT
                    Center(
                      child: Text(
                        isInvalid
                            ? 'Changes are saved locally until fleet review'
                            : '⚖ LETHBRIDGE TAXI COMMISSION BYLAW 5834 COMPLIANT',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM ACTION BUTTON
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    key: const ValueKey('driver_register_step2_submit_button'),
                    onPressed: isValid && !state.isSubmitting
                        ? () => bloc.add(const DriverRegisterStep2Submitted())
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: isValid ? 2 : 0,
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isValid
                                ? 'Next: Driver documents ➔'
                                : (isInvalid
                                    ? 'Continue to Step 3 ➔'
                                    : 'Next: Upload documents ➔'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isValid
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                  ),
                ),
              ),

              // MODAL OVERLAY: VEHICLE YEAR PICKER (Screen 3)
              if (state.isYearPickerOpen)
                GestureDetector(
                  onTap: () =>
                      bloc.add(const DriverRegisterYearPickerDismissed()),
                  child: Container(
                    color: Colors.black54,
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {}, // Prevent taps inside modal from closing
                      child: DriverVehicleYearModal(
                        selectedYear: state.selectedYearInPicker,
                        onYearSelected: (year) {
                          bloc.add(DriverRegisterYearSelected(year));
                        },
                        onConfirm: () {
                          bloc.add(DriverRegisterYearSelected(
                              state.selectedYearInPicker));
                        },
                        onDismiss: () {
                          bloc.add(const DriverRegisterYearPickerDismissed());
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required bool isValid,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFEBEE),
            ),
            child: Icon(icon, color: const Color(0xFFC62828), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Color(0xFF6B7280),
                  ),
                ),
                TextFormField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isValid)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(
                Icons.check,
                size: 14,
                color: Color(0xFF2E7D32),
              ),
            ),
        ],
      ),
    );
  }
}
