import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  void _navigateToNextPage() {
    if (_currentPageIndex < 1) {
      _pageController.animateToPage(
        _currentPageIndex + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Navigate to '/SignUp' route
      Navigator.pushReplacementNamed(context, '/SignUp');
    }
  }

  void _navigateToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageController.animateToPage(
        _currentPageIndex - 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(100, 100, 100, 1),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              "CryptedEye",
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " > Welcome",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(100, 100, 100, 1),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [CryptedEyeWelcome(), MultipleVaults()],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(100, 100, 100, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _currentPageIndex == 0
                ? const SizedBox()
                : IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed: _navigateToPreviousPage,
                    color: Colors.white,
                  ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPageIndex == 0
                        ? Colors.white
                        : Colors.grey, // Active page color
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPageIndex == 1
                        ? Colors.white
                        : Colors.grey, // Active page color
                  ),
                ),
              ],
            ),
            _currentPageIndex == 1
                ? SizedBox(
                    width: 140,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToNextPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Sign Up'),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.navigate_next),
                    onPressed: _navigateToNextPage,
                    color: Colors.white,
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class CryptedEyeWelcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Image.asset(
            "lib/images/CryptedEye.png",
            width: 300,
          ),
          const SizedBox(
            height: 30,
          ),
          const SizedBox(
            width: 300,
            child: Text(
              "CryptedEye is a fully local vault, with the automatic creation of salt and Key, making your data locked using an Access Password (don't forget it!). With CryptedEye, you can easily and securely save passwords and notes.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MultipleVaults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Image.asset(
            "lib/images/MultiVaults.png",
            width: 300,
          ),
          const SizedBox(
            height: 30,
          ),
          const SizedBox(
            width: 300,
            child: Text(
              "CryptedEye also allows you to export, import, and switch between vaults. Simply export your vault in the settings, share the image file wherever you need!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
