// Updated DashBoardScreen with proper cart initialization

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import 'package:rjfruits/view/HomeView/home_view.dart';
import 'package:rjfruits/view/cart/cart_page.dart';
import 'package:rjfruits/view/profileView/profile_view.dart';
import 'package:rjfruits/view_model/cart_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart'; // Add this import

import '../../res/components/colors.dart';
import '../saveView/save_view.dart';
import '../shopView/shop_view.dart';

class DashBoardScreen extends StatefulWidget {
  int? tabIndex = 0;
  DashBoardScreen({super.key, this.tabIndex});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectIndex = 0;

  onItemClick(int index) {
    setState(() {
      selectIndex = index;
      tabController!.index = selectIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    selectIndex = widget.tabIndex ?? 0;

    tabController = TabController(length: 5, vsync: this);
    tabController!.index = selectIndex;

    // Load cart data when dashboard is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartData();
    });
  }

  void _loadCartData() async {
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final cartProvider = Provider.of<CartRepositoryProvider>(context, listen: false);

      // Get user token
      final userModel = await userViewModel.getUser();
      final token = userModel.key;

      if (token != null && token.isNotEmpty) {
        // Load cart data
        await cartProvider.getCachedProducts(context, token);
      }
    } catch (e) {
      print('Error loading cart data: $e');
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  // Widget to create cart icon with badge
  Widget _buildCartIconWithBadge() {
    return Consumer<CartRepositoryProvider>(
      builder: (context, cartProvider, child) {
        int itemCount = cartProvider.getTotalItemCount();

        return SizedBox(
          width: 30, // give enough space to avoid clipping
          height: 30,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: ImageIcon(AssetImage('images/ds.png')),
                ),
              ),
              if (itemCount > 0)
                Positioned(
                  right: -6, // push it slightly outwards
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      itemCount > 99 ? '99+' : itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          HomeView(),
          CartView(),
          ShopView(),
          SaveView(),
          ProfileView()
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            items: [
              const BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('images/homeIcon.png')),
                label: ('Home'),
              ),
              BottomNavigationBarItem(
                icon: _buildCartIconWithBadge(),
                label: ('Cart'),
              ),
              const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.abc,
                    color: Colors.transparent,
                  ),
                  label: ''),
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite_border,
                ),
                label: ('Wishlist'),
              ),
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.account_circle_outlined,
                ),
                label: ('Profile'),
              ),
            ],
            unselectedItemColor: AppColor.dashboardIconColor,
            selectedItemColor: AppColor.primaryColor,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            currentIndex: selectIndex > 2 ? selectIndex : selectIndex,
            onTap: (index) {
              if (index == 2) {
                onItemClick(2);
              } else {
                onItemClick(index > 2 ? index : index);
              }
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55.0,
              height: 55.0,
              decoration: BoxDecoration(
                color: selectIndex == 2
                    ? AppColor.primaryColor
                    : AppColor.primaryColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    blurRadius: 8.1,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: () {
                  onItemClick(2);
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'images/shop.png',
                      fit: BoxFit.contain,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Shop",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selectIndex == 2
                    ? AppColor.primaryColor
                    : AppColor.primaryColor,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}