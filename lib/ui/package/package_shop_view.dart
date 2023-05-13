import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbuyandsell/api/common/ps_resource.dart';
import 'package:flutterbuyandsell/api/common/ps_status.dart';
import 'package:flutterbuyandsell/config/ps_colors.dart';
import 'package:flutterbuyandsell/constant/ps_constants.dart';
import 'package:flutterbuyandsell/constant/ps_dimens.dart';
import 'package:flutterbuyandsell/provider/package_bought/package_bought_provider.dart';
import 'package:flutterbuyandsell/repository/package_bought_repository.dart';
import 'package:flutterbuyandsell/ui/common/base/ps_widget_with_multi_provider.dart';
import 'package:flutterbuyandsell/ui/common/dialog/error_dialog.dart';
import 'package:flutterbuyandsell/ui/common/dialog/success_dialog.dart';
import 'package:flutterbuyandsell/ui/common/ps_ui_widget.dart';
import 'package:flutterbuyandsell/ui/package/package_item.dart';
import 'package:flutterbuyandsell/utils/ps_progress_dialog.dart';
import 'package:flutterbuyandsell/utils/utils.dart';
import 'package:flutterbuyandsell/viewobject/api_status.dart';
import 'package:flutterbuyandsell/viewobject/common/ps_value_holder.dart';
import 'package:flutterbuyandsell/viewobject/holder/package_bought_parameter_holder.dart';
import 'package:flutterbuyandsell/viewobject/package.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class PackageShopInAppPurchaseView extends StatefulWidget {
  const PackageShopInAppPurchaseView();
  @override
  _PackageShopInAppPurchaseViewState createState() =>
      _PackageShopInAppPurchaseViewState();
}

class _PackageShopInAppPurchaseViewState
    extends State<PackageShopInAppPurchaseView> {
  /// Is the API available on the device
  // bool available = true;

  /// Updates to purchases
//  late StreamSubscription<List<PurchaseDetails>> _subscription;

  PackageBoughtRepository? repo1;
  PsValueHolder? psValueHolder;
  PackageBoughtProvider? packageBoughtProvider;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    //  _initialize();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {}
    });
    super.initState();
  }

  @override
  void dispose() {
    //  _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<PackageBoughtRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          iconTheme: Theme.of(context)
              .iconTheme
              .copyWith(color: PsColors.backArrowColor),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
          ),
          // backgroundColor:
          //     Utils.isLightMode(context) ? PsColors.activeColor : Colors.black12,
          title: Text(
            Utils.getString(
                context, 'item_entry__package_shop'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.bold,
                  //  color: Utils.isLightMode(context)? PsColors.primary500 : PsColors.primaryDarkWhite
                ),
          )),
      body: PsWidgetWithMultiProvider(
        child: MultiProvider(
            providers: <SingleChildWidget>[
              ChangeNotifierProvider<PackageBoughtProvider?>(
                lazy: false,
                create: (BuildContext context) {
                  packageBoughtProvider = PackageBoughtProvider(repo: repo1);
                  packageBoughtProvider!.getAllPackages();

                  return packageBoughtProvider;
                },
              ),
            ],
            child: Consumer<PackageBoughtProvider>(
              builder: (BuildContext context, PackageBoughtProvider provider,
                  Widget? child) {
                return Container(
                  padding: const EdgeInsets.only(top: PsDimens.space10,right: PsDimens.space8),
                  color: PsColors.baseColor,
                  child: Stack(
                    children: <Widget>[
                      RefreshIndicator(
                        child: CustomScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            slivers: <Widget>[
                              SliverGrid(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                  maxCrossAxisExtent:
                                                      220.0,
                                                  childAspectRatio:
                                                      1.40),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    if (provider.packageList.data !=
                                            null ||
                                        provider.packageList.data!
                                            .isNotEmpty) {
                                      // final int count =
                                      //     provider.packageList.data!.length;
                                      final Package package = provider
                                          .packageList.data![index];
                                      return PackageItem(
                                        package: package,
                                        onTap: () async {
                                                  await PsProgressDialog
                                                      .showDialog(
                                                          context);
                                                  final PackgageBoughtParameterHolder
                                                      packgageBoughtParameterHolder =
                                                      PackgageBoughtParameterHolder(
                                                          userId: psValueHolder!.loginUserId,
                                                          packageId:
                                                              package
                                                                  .packageId,
                                                          paymentMethod:
                                                              PsConst
                                                                  .PAYMENT_IN_APP_PURCHASE_METHOD,
                                                          price: package
                                                              .price,
                                                          razorId: '',
                                                          isPaystack:
                                                              PsConst
                                                                  .ZERO);
                                                  final PsResource<
                                                          ApiStatus>
                                                      packageBoughtStatus =
                                                      await provider
                                                          .buyAdPackge(
                                                              packgageBoughtParameterHolder
                                                                  .toMap());
                                                  PsProgressDialog
                                                      .dismissDialog();
                                                  if (packageBoughtStatus
                                                          .status ==
                                                      PsStatus
                                                          .SUCCESS) {
                                                    showDialog<
                                                            dynamic>(
                                                        context:
                                                            context,
                                                        builder:
                                                            (BuildContext
                                                                contet) {
                                                          return SuccessDialog(
                                                            message: Utils.getString(
                                                                context,
                                                                'item_entry__buy_package_success'),
                                                            onPressed:
                                                                () {
                                                              Navigator.pop(
                                                                  context,
                                                                  package.postCount
                                                                  );
                                                            },
                                                          );
                                                        });
                                                  } else {
                                                    showDialog<
                                                            dynamic>(
                                                        context:
                                                            context,
                                                        builder:
                                                            (BuildContext
                                                                context) {
                                                          return ErrorDialog(
                                                            message:
                                                                packageBoughtStatus
                                                                    .message,
                                                          );
                                                        });
                                                  }
                                                },
                                      ); 
                                      
                                    } else {
                                      return null;
                                    }
                                  },
                                  childCount:
                                      provider.packageList.data!.length,
                                ),
                              ),
                            ]),
                        onRefresh: () {
                          return packageBoughtProvider!
                              .getAllPackages();
                        },
                      ),
                      PSProgressIndicator(provider.packageList.status)
                    ],
                  ),
                );
              },
            )),
      ),
    );
  }
}
