import 'package:beautyhup/blocs/add_service/add_service_event.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:beautyhup/blocs/add_service/add_service_state.dart';
import 'package:beautyhup/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/add_service/add_service_bloc.dart';
import '../add_service/add_service_page.dart';

class UpdateService extends StatefulWidget {
  final id;
  const UpdateService({super.key, required this.id});

  @override
  State<UpdateService> createState() => _UpdateServiceState();
}

class _UpdateServiceState extends State<UpdateService> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddServiceBloc(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const StepBasicInfo(),
              const Divider(height: 1, thickness: 0.8),
              const StepInstructions(),
              BlocBuilder<AddServiceBloc, AddServiceState>(
                  builder: (context, state) {
                return PrimaryButton(
                  variant: PrimaryButtonVariant.filled,
                  isLoading:
                      state.status == AddServiceStatus.loading ? true : false,
                  label: context.l10n.update,
                  onPressed: () async {
                    print('=========================');
                    await context.read<AddServiceBloc>()
                      ..add(UpdateServiceBloc(widget.id));
                
                    Navigator.pop(context,true);
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
