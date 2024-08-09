import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/services/auth_service.dart';
import 'package:inmateschedular_pro/util/form_container_widget.dart';
import 'package:provider/provider.dart';

class ChangePasswordDialog extends StatefulWidget {
  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });

      if (_newPasswordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'New passwords do not match';
        });
        return;
      }

      try {
        // Ensure current password is correct
        final user = authService.user;
        if (user != null) {
          await user.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: user.email!,
              password: _currentPasswordController.text,
            ),
          );

          // Update the password
          await user.updatePassword(_newPasswordController.text);

          // Notify success
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Current password is not correct';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password', style: TextStyle(color: Colors.blueAccent)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormContainerWidget(
              controller: _currentPasswordController,
              hintText: "Current Password",
              isPasswordField: true,
              //prefixIcon: Icons.lock,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            FormContainerWidget(
              controller: _newPasswordController,
              hintText: "New Password",
              isPasswordField: true,
              //prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            FormContainerWidget(
              controller: _confirmPasswordController,
              hintText: "Confirm New Password",
              isPasswordField: true,
              //prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                } else if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _changePassword,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
          ),
          child: const Text('Change Password'),
        ),
      ],
    );
  }
}
