import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/analysis_intake_state.dart';
import '../../../domain/models/soil_analysis.dart';
import '../../../domain/models/soil_parameter_classifier.dart';

part 'analysis_workflow_panel.dart';
part 'analysis_import_card.dart';
part 'selected_pdf_card.dart';
part 'analysis_save_success_card.dart';
part 'extracted_analysis_review_section.dart';
part 'document_info_card.dart';
part 'extracted_analysis_review_card.dart';
part 'soil_parameter_chip.dart';

enum _WorkflowStepState { pending, active, complete, error }
