import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final controller = Get.find<ConfigController>();

      controller.getConfigData().then((bool success) {
        if (!success) return;

        final config = controller.config;

        if (config == null) return;

        final maintenance = config.maintenanceMode;

        if (maintenance == null) return;

        // Safe checks
        final status = maintenance.maintenanceStatus ?? 0;
        final selected = maintenance.selectedMaintenanceSystem?.userApp ?? 1;

        if (status == 0 || selected == 0) {
          Get.offAll(() => const DashboardScreen());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ConfigModel? configModel = Get.find<ConfigController>().config;

    final maintenance = configModel?.maintenanceMode;
    final message = maintenance?.maintenanceMessages;

    return Scaffold(
      body: Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.all(size.height * 0.025),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(Images.maintenanceSvg, width: 200, height: 200),
              SizedBox(height: size.height * 0.07),

              if (message?.maintenanceMessage != null &&
                  message!.maintenanceMessage!.isNotEmpty)
                Text(
                  message.maintenanceMessage!,
                  textAlign: TextAlign.center,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w700,
                  ),
                ),

              if (message?.messageBody != null && message!.messageBody!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    message.messageBody!,
                    textAlign: TextAlign.center,
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              if (message?.businessEmail == 1 || message?.businessNumber == 1) ...[
                if ((message?.maintenanceMessage?.isNotEmpty ?? false) ||
                    (message?.messageBody?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: List.generate(
                        size.width ~/ 10,
                            (index) => Expanded(
                          child: Container(
                            height: 2,
                            color: index % 2 == 0
                                ? Colors.transparent
                                : Theme.of(context).hintColor.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  ),

                Text(
                  'Any query? Feel free to call:',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 10),

                if (message?.businessNumber == 1)
                  InkWell(
                    onTap: () {
                      if (configModel?.businessSupportPhone != null) {
                        launchUrl(
                          Uri.parse('tel:${configModel!.businessSupportPhone}'),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(
                      configModel?.businessSupportPhone ?? '',
                      style: textRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),

                if (message?.businessEmail == 1)
                  InkWell(
                    onTap: () {
                      if (configModel?.businessSupportEmail != null) {
                        launchUrl(
                          Uri.parse('mailto:${configModel!.businessSupportEmail}'),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(
                      configModel?.businessSupportEmail ?? '',
                      style: textRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
