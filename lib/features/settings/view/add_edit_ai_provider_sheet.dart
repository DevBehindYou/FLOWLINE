import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/services/ai_settings_validation.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';
import '../viewmodel/ai_providers_view_model.dart';

class AddEditAiProviderSheet extends ConsumerStatefulWidget {
  const AddEditAiProviderSheet({super.key, required this.config});

  final AIProviderConfig config;

  @override
  ConsumerState<AddEditAiProviderSheet> createState() =>
      _AddEditAiProviderSheetState();
}

class _AddEditAiProviderSheetState
    extends ConsumerState<AddEditAiProviderSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _apiKeyController = TextEditingController();
  late final TextEditingController _modelController =
      TextEditingController(text: widget.config.defaultModel);
  late final TextEditingController _baseUrlController =
      TextEditingController(text: widget.config.baseUrl ?? '');
  bool _obscureKey = true;
  bool _saving = false;
  String? _error;

  bool get _requiresKey => widget.config.requiresApiKey;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _run(() => ref.read(aiProvidersViewModelProvider.notifier).saveKey(
          id: widget.config.id,
          apiKey: _apiKeyController.text.trim(),
          model: _modelController.text.trim(),
          baseUrl: _requiresKey
              ? widget.config.baseUrl
              : normalizeOllamaBaseUrl(_baseUrlController.text),
        ));
  }

  Future<void> _remove() async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Remove ${widget.config.displayName} key?',
      message: 'The key is deleted from this phone. Your saved conversations '
          'stay, but new messages won\'t work until you add a key again.',
      confirmLabel: 'Remove',
    );
    if (!confirmed || !mounted) return;
    await _run(() => ref
        .read(aiProvidersViewModelProvider.notifier)
        .removeKey(widget.config.id));
  }

  /// Busy flag, error message instead of a stuck spinner, close on success.
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Couldn\'t save — please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSavedKey =
        ref.watch(providerHasKeyProvider(widget.config.id)).value ?? false;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.config.displayName,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_requiresKey)
                TextFormField(
                  controller: _apiKeyController,
                  obscureText: _obscureKey,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) =>
                      validateApiKey(value ?? '', hasSavedKey: hasSavedKey),
                  decoration: InputDecoration(
                    labelText: 'API key',
                    helperText: hasSavedKey
                        ? 'A key is saved. Leave empty to keep it.'
                        : 'Stored only on this phone, in the Android Keystore.',
                    suffixIcon: IconButton(
                      tooltip: _obscureKey ? 'Show key' : 'Hide key',
                      icon: Icon(
                        _obscureKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                )
              else
                TextFormField(
                  controller: _baseUrlController,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: (value) => validateOllamaBaseUrl(value ?? ''),
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'http://localhost:11434',
                    helperText:
                        "On a phone, \"localhost\" means the phone itself — "
                        "use your computer's LAN IP if Ollama runs there.",
                    helperMaxLines: 2,
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                autocorrect: false,
                validator: (value) => validateModelName(value ?? ''),
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              const SizedBox(height: 8),
              if (_requiresKey && hasSavedKey)
                TextButton(
                  onPressed: _saving ? null : _remove,
                  child: const Text('Remove key'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
