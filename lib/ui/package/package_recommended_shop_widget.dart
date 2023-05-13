import 'package:flutter/material.dart';
import 'package:flutterbuyandsell/api/common/ps_resource.dart';
import 'package:flutterbuyandsell/api/common/ps_status.dart';
import 'package:flutterbuyandsell/config/ps_colors.dart';
import 'package:flutterbuyandsell/constant/ps_constants.dart';
import 'package:flutterbuyandsell/constant/route_paths.dart';
import 'package:flutterbuyandsell/provider/package_bought/package_bought_provider.dart';
import 'package:flutterbuyandsell/ui/common/dialog/error_dialog.dart';
import 'package:flutterbuyandsell/ui/common/dialog/success_dialog.dart';
import 'package:flutterbuyandsell/ui/common/ps_frame_loading_widget.dart';
import 'package:flutterbuyandsell/ui/common/ps_header_widget.dart';
import 'package:flutterbuyandsell/ui/package/package_item.dart';
import 'package:flutterbuyandsell/utils/ps_progress_dialog.dart';
import 'package:flutterbuyandsell/utils/utils.dart';
import 'package:flutterbuyandsell/viewobject/api_status.dart';
import 'package:flutterbuyandsell/viewobject/common/ps_value_holder.dart';
import 'package:flutterbuyandsell/viewobject/holder/package_bought_parameter_holder.dart';
import 'package:flutterbuyandsell/viewobject/package.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PackageRecommendedWidget extends StatefulWidget {
  const PackageRecommendedWidget({required this.callToRefresh});
  final Function callToRefresh;

  @override
  PackageRecommendedWidgetState createState() =>
      PackageRecommendedWidgetState();
}

class PackageRecommendedWidgetState extends State<PackageRecommendedWidget> {
  PsValueHolder? psValueHolder;
  PackageBoughtProvider? packageBoughtProvider;
  final int recommendedPackageCount = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    psValueHolder = Provider.of<PsValueHolder>(context);

    return SliverToBoxAdapter(
      child: Consumer<PackageBoughtProvider>(
        builder: (BuildContext context, PackageBoughtProvider provider,
            Widget? child) {
          if (provider.packageList.data != null ||
              provider.packageList.data!.isNotEmpty)
            return Container(
              height: 220,
              child: Column(
                children: <Widget>[
                  PsHeaderWidget(
                    headerName:
                        Utils.getString(context, 'package__recommended'),
                    viewAllClicked: () async {
                      await Navigator.pushNamed(
                        context,
                        RoutePaths.buyPackage,
                      );
                      //  widget.callToRefresh();
                    },
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Container(
                            child: CustomScrollView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                slivers: <Widget>[
                              SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 220.0,
                                        childAspectRatio: 1.40),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    // final int count =
                                    //     provider.packageList.data!.length;
                                    
                                    if (provider.packageList.status ==
                                        // ignore: unnecessary_null_comparison
                                        PsStatus.BLOCK_LOADING) {
                                      return Shimmer.fromColors(
                                          baseColor: PsColors.grey,
                                          highlightColor: PsColors.white,
                                          child: Row(children: const <Widget>[
                                            PsFrameUIForLoading(),
                                          ]));
                                    } else {
                                      final Package package =
                                        provider.packageList.data![index];
                                        return PackageItem(
                                        package: package,
                                        onTap: () async {
                                          await PsProgressDialog.showDialog(
                                              context);
                                          final PackgageBoughtParameterHolder
                                              packgageBoughtParameterHolder =
                                              PackgageBoughtParameterHolder(
                                                  userId: psValueHolder!
                                                      .loginUserId,
                                                  packageId: package.packageId,
                                                  paymentMethod: PsConst
                                                      .PAYMENT_IN_APP_PURCHASE_METHOD,
                                                  price: package.price,
                                                  razorId: '',
                                                  isPaystack: PsConst.ZERO);
                                          final PsResource<ApiStatus>
                                              packageBoughtStatus =
                                              await provider.buyAdPackge(
                                                  packgageBoughtParameterHolder
                                                      .toMap());
                                          PsProgressDialog.dismissDialog();
                                          if (packageBoughtStatus.status ==
                                              PsStatus.SUCCESS) {
                                            showDialog<dynamic>(
                                                context: context,
                                                builder: (BuildContext contet) {
                                                  return SuccessDialog(
                                                    message: Utils.getString(
                                                        context,
                                                        'item_entry__buy_package_success'),
                                                    onPressed:
                                                        widget.callToRefresh,
                                                  );
                                                });
                                          } else {
                                            showDialog<dynamic>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return ErrorDialog(
                                                    message: packageBoughtStatus
                                                        .message,
                                                  );
                                                });
                                          }
                                        },
                                      );
                                    }
                                      
                                  },
                                  childCount: recommendedPackageCount,
                                ),
                              ),
                            ])),
                        //  PSProgressIndicator(provider.packageList.status)
                      ],
                    ),
                  )
                ],
              ),
            );
          else
            return Container();
        },
      ),
    );
  }
}
