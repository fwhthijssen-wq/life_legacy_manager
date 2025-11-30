import 'package:flutter/material.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';
import 'dart:math';

/// Verify Recovery Phrase Screen
/// Asks user to verify they wrote down the recovery phrase correctly
/// by entering 3 random words from their 12-word phrase
class VerifyRecoveryPhraseScreen extends StatefulWidget {
  final List<String> recoveryPhrase;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const VerifyRecoveryPhraseScreen({
    super.key,
    required this.recoveryPhrase,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<VerifyRecoveryPhraseScreen> createState() => _VerifyRecoveryPhraseScreenState();
}

class _VerifyRecoveryPhraseScreenState extends State<VerifyRecoveryPhraseScreen> {
  late List<int> _verificationIndices;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  String? _errorMessage;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _generateVerificationIndices();
    
    // Create controllers and focus nodes
    for (int i = 0; i < 3; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Generate 3 random indices to verify (0-11)
  void _generateVerificationIndices() {
    final random = Random();
    final indices = <int>[];
    
    while (indices.length < 3) {
      final index = random.nextInt(12);
      if (!indices.contains(index)) {
        indices.add(index);
      }
    }
    
    // Sort for better UX
    indices.sort();
    _verificationIndices = indices;
  }

  Future<void> _verifyWords() async {
    setState(() {
      _errorMessage = null;
      _isVerifying = true;
    });

    // Simulate slight delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    // Check each word
    bool allCorrect = true;
    for (int i = 0; i < 3; i++) {
      final userInput = _controllers[i].text.trim().toLowerCase();
      final expectedWord = widget.recoveryPhrase[_verificationIndices[i]].toLowerCase();
      
      if (userInput != expectedWord) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      _isVerifying = false;
      if (!allCorrect) {
        final l10n = AppLocalizations.of(context)!;
        _errorMessage = l10n.recoveryPhraseConfirmError;
      }
    });

    if (allCorrect) {
      // Success!
      widget.onVerified();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recoveryPhraseConfirmTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.verified_user_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                l10n.recoveryPhraseConfirmSubtitle,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Verification Fields
              ...List.generate(3, (index) {
                final wordNumber = _verificationIndices[index] + 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildVerificationField(
                    context,
                    wordNumber,
                    _controllers[index],
                    _focusNodes[index],
                    isLast: index == 2,
                  ),
                );
              }),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Verify Button
              FilledButton(
                onPressed: _isVerifying ? null : _verifyWords,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.confirm),
              ),

              const SizedBox(height: 16),

              // Back Button
              OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.recoveryPhraseShowAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationField(
    BuildContext context,
    int wordNumber,
    TextEditingController controller,
    FocusNode focusNode,
    {bool isLast = false}
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vul woord #$wordNumber in',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Woord $wordNumber',
            prefixIcon: Container(
              width: 48,
              alignment: Alignment.center,
              child: Text(
                '$wordNumber',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
          onSubmitted: (_) {
            if (!isLast) {
              // Move to next field
              FocusScope.of(context).nextFocus();
            } else {
              // Last field, verify
              _verifyWords();
            }
          },
          onChanged: (_) {
            // Clear error when user types
            if (_errorMessage != null) {
              setState(() {
                _errorMessage = null;
              });
            }
          },
        ),
      ],
    );
  }
}
