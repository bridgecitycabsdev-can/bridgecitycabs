class DriverRegisterConfig {
  static const String screenTitle = 'Personal Details';
  static const String stepInfo = 'Step 1 of 4 · Personal info';
  static const String requiredBadge = 'REQUIRED';
  static const String percentageBadge = '25%';

  // Profile Photo
  static const String addPhotoHeading = 'Add a clear profile photo';
  static const String requiredRedTag = '(Required)';
  static const String addPhotoSubtitle =
      'Take a clear headshot looking directly at the camera with good lighting';
  static const String photoAddedSuccess = 'Profile photo added';
  static const String changePhotoAction = 'Change';
  static const String photoRequiredError =
      'Profile photo is required to continue';
  static const String photoBylawSubtext =
      'Lethbridge City Bylaw requires a clear portrait headshot.';

  // Photo Bottom Sheet Modal
  static const String modalTitle = 'Add profile photo';
  static const String modalSubtitle =
      'A clear front-facing photo helps passengers identify you at pickup.';
  static const String badgeIdTitle = 'DRIVER BADGE ID';
  static const String badgeIdSubtitle =
      'Visible on rider booking & Lethbridge dispatch console';
  static const String guidelineLighting = 'Good lighting';
  static const String guidelineSunglasses = 'No sunglasses';
  static const String guidelineFaceForward = 'Face forward';
  static const String takePhotoAction = 'Take photo';
  static const String chooseGalleryAction = 'Choose from gallery';
  static const String cancelAction = 'Cancel';
  static const String policeBylawNotice =
      'Lethbridge Police Service Bylaw 5824 Compliant';

  // Form Labels
  static const String firstNameLabel = 'First name';
  static const String lastNameLabel = 'Last name';
  static const String emailLabel = 'Email address';
  static const String phoneLabel = 'Phone number';
  static const String licenceLabel = 'Alberta licence number';
  static const String licenceClassTag = 'Class 1, 2, or 4';
  static const String postalCodeLabel = 'Postal code';
  static const String genderLabel = 'Gender';
  static const String genderOptionalTag = '(Optional)';
  static const String genderIdentificationLabel = 'Gender identification';
  static const String genderOfficialIdLabel = 'Gender on official ID';

  // Placeholders
  static const String emailPlaceholder = 'Email address (e.g. name@email.com)';
  static const String licencePlaceholder = 'DRIVER LICENCE NUMBER (E.G. 12...';
  static const String postalCodePlaceholder = 'POSTAL CODE (E.G. T1K 3M4)';

  // Verification Badges
  static const String verifiedViaSms = 'Verified via SMS code';
  static const String verifiedBadge = 'VERIFIED';
  static const String smsVerifiedBadge = 'SMS Verified';

  // Field Errors
  static const String invalidSyntaxError = 'Invalid syntax';
  static const String invalidEmailError = 'Enter a valid email address';
  static const String licenceRequiredError =
      'Driver licence number is required';
  static const String postalCodeInvalidError =
      'Enter a valid postal code (e.g. T1K 3M4)';
  static const String generalValidationAlert =
      'Please correct the highlighted errors above';

  // Regulatory Notices
  static const String taxiCommissionNotice =
      'Your details are only used to verify you as an authorized driver with the Lethbridge City Taxi Commission.';
  static const String privacyProtectedTitle = 'Privacy protected';
  static const String privacyProtectedDesc =
      'Your details are strictly encrypted and solely used to verify your commercial driving status with the City of Lethbridge.';
  static const String identityAuditTitle = 'Identity & Regulatory Audit';
  static const String identityAuditDesc =
      'Your details are only used to verify you as a certified driver in Lethbridge under Municipal Bylaw 5834. Never shared publicly.';

  // Buttons
  static const String nextStepButtonText = 'Next Step';
  static const String nextVehicleDetailsButtonText = 'Next: Vehicle details';
  static const String continueToVehicleInfoButtonText =
      'Continue to Vehicle Info';

  // Step 2: Your Vehicle
  static const String step2ScreenTitle = 'Your Vehicle';
  static const String step2Info = 'Step 2 of 4 · Vehicle';
  static const String step2CompletedBadge = '50% Completed';
  static const String step2Percentage = '50%';
  static const String vehicleClassLabel = 'VEHICLE CLASS';
  static const String vehicleTypeLabel = 'VEHICLE TYPE';
  static const String vehicleCategoryLabel = 'Vehicle Category';
  static const String verifiedForFleet = 'Verified for Fleet';
  static const String selectClassificationDesc =
      'Select your vehicle classification to set dispatch tiers.';
  static const String fleetInspectionApproved = 'FLEET INSPECTION APPROVED';
  static const String allFieldsConfirmed = 'All fields confirmed';
  static const String selectSizeLabel = 'Select size';

  // Vehicle Specifications
  static const String vehicleSpecsLabel = 'VEHICLE SPECIFICATIONS';
  static const String vehicleMakePlaceholder = 'Vehicle make (e.g. Toyota)';
  static const String vehicleModelPlaceholder =
      'Vehicle model (e.g. Camry, RAV4)';
  static const String modelYearLabel = 'MODEL YEAR';
  static const String exteriorColourLabel = 'EXTERIOR COLOUR';
  static const String yearOfManufactureLabel = 'Year of Manufacture';
  static const String min2014ReqTag = 'Min. 2014 req.';

  // Alberta License Plate
  static const String wildRoseCountry = 'WILD ROSE COUNTRY';
  static const String albertaText = 'ALBERTA';
  static const String commercialTaxi = 'COMMERCIAL TAXI';
  static const String registeredWithRegistry =
      'Registered with Lethbridge Vehicle Registry';
  static const String enterExactPlateNotice =
      'Enter exact registration plate as issued';

  // Dispatch & Ride Preferences
  static const String dispatchPreferencesLabel = 'DISPATCH PREFERENCES';
  static const String ridePreferencesLabel = 'RIDE PREFERENCES';
  static const String dispatchCapabilitiesLabel = 'DISPATCH CAPABILITIES';
  static const String vanOnlyTitle = 'Suitable for van-only requests';
  static const String vanOnlySubtitleStandard =
      'Vehicle capacity standard (4 seats)';
  static const String vanOnlySubtitleLuggage =
      'For luggage or 5+ passenger dispatches';
  static const String vanOnlySubtitleRamp = 'Luggage ramp or 6+ full capacity';
  static const String femaleDriverTitle = 'Female driver requests';
  static const String femaleDriverSubtitle =
      'Available for lady-rider-only requests';
  static const String ladyDriverTitle = 'Lady-driver-only requests';
  static const String ladyDriverSubtitle =
      'Opt-in active for Lethbridge safety network';

  // Quality Standards & Bylaw
  static const String qualityStandardsTitle =
      'Bridge City Cabs Quality Standards';
  static const String qualityStandardsDesc =
      'Your vehicle must be in good condition, smoke-free, and pass semi-annual mechanical inspections per municipal guidelines.';
  static const String vehicleRequirementsTitle = 'Vehicle Requirements';
  static const String vehicleRequirementsDesc =
      'Your vehicle must be in clean condition, 2014 or newer, and meet Bridge City Cabs & Lethbridge safety inspection standards.';
  static const String bylaw5834OlderThan10YearsTitle =
      'Lethbridge City Bylaw #5834';
  static const String bylaw5834OlderThan10YearsDesc =
      'Vehicles older than 10 years cannot be registered under Lethbridge municipal taxi regulations.';
  static const String bylaw5834CompliantFooter =
      'LETHBRIDGE TAXI COMMISSION BYLAW 5834 COMPLIANT';
  static const String localReviewFooter =
      'Changes are saved locally until fleet review';

  // Step 2 Errors
  static const String yearTooOldError =
      'Vehicle year is too old (Must be 2014 or newer for Lethbridge fleet)';
  static const String plateInvalidError =
      'Enter a valid plate number (e.g. ABC-1234)';

  // Year Modal
  static const String selectVehicleYearTitle = 'Select Vehicle year';
  static const String yearRequirementNotice =
      'Vehicles must be model year 2014 or newer to qualify for Bridge City Cabs in Lethbridge.';
  static const String confirmYearButtonText = 'Confirm Year';
  static const String doneAction = 'Done';

  // Step 2 Buttons
  static const String nextDriverDocsButtonText = 'Next: Driver documents';
  static const String nextUploadDocsButtonText = 'Next: Upload documents';
  static const String continueToStep3ButtonText = 'Continue to Step 3';

  // Step 3: Documents & Compliance
  static const String step3AppBarTitle = 'Step 2: Vehicle & Documentation';
  static const String step3BadgeApplication = 'APPLICATION';
  static const String step3Info = 'Step 3 of 4 · Documents';
  static const String step3CompletedBadge = '75% Completed';
  static const String step3Percentage = '75%';
  static const String step3AllRequiredAttached = 'All Required Docs Attached';
  static const String step3ReadyComplianceTitle = 'Ready for Fleet Compliance';
  static const String step3ReadyComplianceDesc =
      'All 3 required documents verified and ready for fleet compliance review.';
  static const String step3UploadClearPhotos =
      'Upload clear photos. Make sure all text is readable and corners are visible.';
  static const String step3UploadClearPhotosShort =
      'Upload clear photos. Make sure all text is readable.';
  static const String step3ComplianceDocuments = 'Compliance Documents';
  static const String step3LethbridgeBylaw6251 =
      'Lethbridge City Bylaw 6251 requirements';
  static const String step3OneActionRequired = '1 ACTION REQUIRED';
  static const String step3LicenceNeedsReuploadTitle =
      "Driver's licence needs re-upload";
  static const String step3LicenceNeedsReuploadDesc =
      'The photo uploaded is blurry and text cannot be verified by automated screening. Please re-take.';
  static const String step3AutomatedCheckFailed = 'AUTOMATED CHECK FAILED';
  static const String step3AutomatedCheckFailedDesc =
      'Image is blurry and corners are cut off. Please retake in good lighting without flash glare.';
  static const String step3RetakeButtonText = 'Retake photo / Re-upload';
  static const String step3TransmittingToFleet = 'Transmitting to Fleet...';
  static const String step3UploadingEncryptedServer =
      'Uploading encrypted documents to Bridge City Cabs safety server...';
  static const String step3SystemProtocolActive = 'SYSTEM PROTOCOL ACTIVE';
  static const String step3SystemProtocolDesc =
      'Verifying document signatures & municipal compliance with Lethbridge Taxi Commission...';
  static const String step3SslChannelTitle = 'SSL/TLS 256-Bit Channel';
  static const String step3DoNotCloseWarning =
      'Do not close or leave the app while submitting.';
  static const String step3PleaseWaitForUploads =
      'Please wait for uploads to complete';
  static const String step3SubmitForReview = 'Submit for review';
  static const String step3SubmittingReview = 'Submitting for review...';
  static const String step3EncryptedCompliantTitle =
      '256-Bit Encrypted & Compliant';
  static const String step3EncryptedCompliantDesc =
      'Your documents are securely encrypted. Bridge City Cabs reviews submissions within 2–4 hours during business days.';
  static const String step3VaultSecurityNotice =
      'Your documents are stored securely with 256-bit encryption and only reviewed by the Bridge City Cabs fleet safety team.';
  static const String step3ModalStepTag = 'Step 3 of 4';
  static const String step3ModalSubtitle =
      'Select how you would like to provide your document photo or file.';
  static const String step3TakePhoto = 'Take photo';
  static const String step3TakePhotoSubtitle =
      'Use device camera (Front & Back)';
  static const String step3ChooseGallery = 'Choose from gallery';
  static const String step3ChooseGallerySubtitle =
      'JPG or PNG from your photo library';
  static const String step3UploadPdf = 'Upload PDF';
  static const String step3UploadPdfSubtitle =
      'Official digital document or scan (Max 10 MB)';
  static const String step3GoodLighting = 'Good lighting';
  static const String step3NoGlare = 'No glare';
  static const String step3AllCornersVisible = 'All 4 corners visible';
  static const String step3SupportDesk = 'Bridge City Support available 24/7';
  static const String step3CallDeskAction = 'Call Desk';
  static const String step3Fix1IssueWarning =
      'Please fix 1 highlighted issue above before submitting.';
  static const String step3DirectDepositFooter =
      'You will proceed to step 4 (Direct Deposit) once verified.';

  // Step 4: Review, Approval & Final Status
  static const String step4TopFleetTitle = 'LETHBRIDGE FLEET';
  static const String step4TopPendingApproval = 'Pending Approval';
  static const String step4LogOutAction = 'Log Out';
  static const String step4ApprovedHeader = 'STEP 4 OF 4 · APPROVED';
  static const String step4ReviewHeader = 'STEP 4 OF 4 · REVIEW';
  static const String step4ActionRequiredHeader = 'STEP 4 OF 4 · ACTION REQUIRED';
  static const String step4StatusHeader = 'STEP 4 OF 4 · APPLICATION STATUS';
  static const String step4ApprovedTitle = "You're approved!";
  static const String step4ApprovedSubtitle =
      'You can now go online and start receiving rides in Lethbridge.';
  static const String step4ReviewingTitle = "We're reviewing your documents";
  static const String step4ReviewingSubtitle =
      "This usually takes 1 to 2 business days. We'll notify you via push and SMS as soon as you're cleared to drive.";
  static const String step4ActionRequiredTitle =
      'Action needed on your application';
  static const String step4ActionRequiredSubtitle =
      'One of your documents needs to be re-uploaded before we can activate your driver account.';
  static const String step4AppOnHoldTitle = 'Application temporarily on hold';
  static const String step4AppOnHoldSubtitle =
      'Please update the flagged document. Once uploaded, review resumes rapidly within 2 hours by dispatch.';
  static const String step4RejectedTitle = 'Application could not be approved';
  static const String step4RejectedSubtitle =
      'Your vehicle model year (2008) does not meet Lethbridge Taxi Commission Bylaw 5834 requirement (must be 2014 or newer).';
  static const String step4OfflineTitle = "You're offline. Reconnecting...";
  static const String step4OfflineSubtitle =
      'Checking Lethbridge dispatch server connection...';
  static const String step4GoToHome = 'Go to home';
  static const String step4RefreshStatus = 'Refresh status';
  static const String step4FixDocuments = 'Fix documents';
  static const String step4ReuploadOrUpdate =
      'Re-upload documents / Update vehicle';
  static const String step4ReconnectingToServer = 'Reconnecting to server...';
  static const String step4ContactSupport = 'Contact support';
  static const String step4OfflinePhone = '403-328-8888';
  static const String step4AutoCheckNotice =
      'Auto-checking every 60 seconds · Lethbridge Dispatch Hub';
}
