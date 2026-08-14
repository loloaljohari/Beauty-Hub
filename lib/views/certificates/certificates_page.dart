import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../data/models/training_models.dart';
import '../../widgets/state_views.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/certificates/certificates_bloc.dart';
import '../../blocs/certificates/certificates_event.dart';
import '../../blocs/certificates/certificates_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/training_cards.dart';

/// "My Certificates" - All / Created by me / from Salon & Center tabs.
class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CertificatesBloc()..add(const CertificatesLoaded()),
      child: const _CertificatesView(),
    );
  }
}

class _CertificatesView extends StatelessWidget {
  const _CertificatesView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            context.l10n.myCertificates,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryGrey,
            indicatorColor: AppColors.primary,
            onTap: (index) => context
                .read<CertificatesBloc>()
                .add(CertificatesTabChanged(index)),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Created by me'),
              Tab(text: 'from Salon & Center'),
            ],
          ),
        ),
        body: BlocBuilder<CertificatesBloc, CertificatesState>(
          builder: (context, state) {
            if (state.status != CertificatesStatus.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final results = state.filteredCertificates;

            if (results.isEmpty) {
              return EmptyState(
                icon: Icons.workspace_premium_outlined,
                title: context.l10n.noCertificates,
                message:
                    context.l10n.certificatesHint??
                    'grant to trainees, both show up on this screen.',
              );
            }
            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenPaddingH.w(context),
                vertical: AppDimens.spaceMd.h(context),
              ),
              children: [
                for (final certificate in results)
                  CertificateCard(
                    certificate: certificate,
                    // The download button was never wired to anything.
                    onDownload: () => _showDocument(context, certificate),
                    onDelete: () => context
                        .read<CertificatesBloc>()
                        .add(CertificateDeleted(certificate.id)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Shows the certificate's document link.
///
/// Opening a URL in the browser needs the `url_launcher` package, which
/// this project does not depend on. Rather than leave the button doing
/// nothing, the link is shown and can be copied - Clipboard is part of
/// Flutter itself, so this adds no dependency.
void _showDocument(BuildContext context, CertificateModel certificate) {
  final url = certificate.documentUrl;

  if (url == null || url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.noDocumentAttached)),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.white,
      title: Text(certificate.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (certificate.certificateNumber != null) ...[
            Text('No. ${certificate.certificateNumber}'),
            const SizedBox(height: 8),
          ],
          SelectableText(
            url,
            style: const TextStyle(fontSize: 13, color: AppColors.textBody),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.close),
        ),
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.linkCopied)),
            );
          },
          child: Text(context.l10n.copyLink),
        ),
      ],
    ),
  );
}
