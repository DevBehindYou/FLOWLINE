import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/ai_provider_config.dart';
import '../viewmodel/ai_providers_view_model.dart';

class AddEditAiProviderSheet extends ConsumerStatefulWidget {
  const AddEditAiProviderSheet({super.key, required this.config});

  final AIProviderConfig config;

  @override
  ConsumerState<AddEditAiProviderSheet> createState() => _AddEditAiProviderSheetState();
}

class _AddEditAiProviderSheetState extends ConsumerState<AddEditAiProviderSheet> {
  late final TextEditingController _apiKeyController = TextEditingController();
  late final TextEditingController _modelController =
      TextEditingController(text: widget.config.defaultModel);
  late final TextEditingController _baseUrlController =
      TextEditingController(text: widget.config.baseUrl ?? '');
  bool _obscureKey = true;
  bool _saving = false;

  bool get _requiresKey => widget.config.requiresApiKey;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(aiProvidersViewModelProvider.notifier).saveKey(
          id: widget.config.id,
          apiKey: _apiKeyController.text.trim(),
          model: _modelController.text.trim(),
          baseUrl: _baseUrlController.text.trim().isEmpty ? null : _baseUrlController.text.trim(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _remove() async {
    setState(() => _saving = true);
    await ref.read(aiProvidersViewModelProvider.notifier).removeKey(widget.config.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.config.displayName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_requiresKey)
              TextField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: 'API key',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              )
            else
              TextField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  helperText: "On a phone, \"localhost\" means the phone itself \u2014 "
                      "use your computer's LAN IP if Ollama runs there.",
                  helperMaxLines: 2,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
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
            if (_requiresKey)
              TextButton(
                onPressed: _saving ? null : _remove,
                child: const Text('Remove key'),
              ),
          ],
        ),
      ),
    );
  }
}
