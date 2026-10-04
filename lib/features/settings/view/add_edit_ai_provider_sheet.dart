import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/services/ai_settings_validation.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';
import '../viewmodel/ai_providers_view_model.dart';
import '../../../l10n/l10n.dart';

String? _message(AppLocalizations l10n, AiFieldError? error) => switch (error) {
      null => null,
      AiFieldError.modelEmpty => l10n.aiFieldModelEmpty,
      AiFieldError.modelHasSpaces => l10n.aiFieldModelHasSpaces,
      AiFieldError.urlNeedsScheme => l10n.aiFieldUrlNeedsScheme,
      AiFieldError.urlNeedsHost => l10n.aiFieldUrlNeedsHost,
      AiFieldError.urlHasPath => l10n.aiFieldUrlHasPath,
      AiFieldError.keyEmpty => l10n.aiFieldKeyEmpty,
      AiFieldError.keyHasSpaces => l10n.aiFieldKeyHasSpaces,
    };

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

  /// Test connection: running, its failure, or the models it found.
  bool _testing = false;
  AIFailure? _testFailure;
  bool _tested = false;
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
      title: context.l10n.removeKeyTitle(widget.config.displayName),
      message: context.l10n.removeKeyMessage,
      confirmLabel: context.l10n.remove,
    );
    if (!confirmed || !mounted) return;
    await _run(() => ref
        .read(aiProvidersViewModelProvider.notifier)
        .removeKey(widget.config.id));
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testFailure = null;
      _tested = false;
    });
    AIFailure? failure;
    try {
      await ref.read(aiProvidersViewModelProvider.notifier).testConnection(
            id: widget.config.id,
            apiKey: _apiKeyController.text.trim(),
            baseUrl: _requiresKey
                ? null
                : normalizeOllamaBaseUrl(_baseUrlController.text),
          );
    } on AIFailureException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = const AIFailure(AIFailureKind.unknown);
    }
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testFailure = failure;
      _tested = true;
    });
  }

  Future<void> _chooseModel(List<AIModelInfo> models) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final m in models)
                ListTile(
                  title: Text(m.label),
                  subtitle: m.displayName == null ? null : Text(m.id),
                  selected: m.id == _modelController.text.trim(),
                  onTap: () => Navigator.pop(context, m.id),
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null) setState(() => _modelController.text = chosen);
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
          _error = context.l10n.saveFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSavedKey =
        ref.watch(providerHasKeyProvider(widget.config.id)).value ?? false;
    final models = ref.watch(providerModelsProvider)[widget.config.id];

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
                  validator: (value) => _message(l10n,
                      validateApiKey(value ?? '', hasSavedKey: hasSavedKey)),
                  decoration: InputDecoration(
                    labelText: l10n.apiKey,
                    helperText: hasSavedKey
                        ? l10n.apiKeySavedHint
                        : l10n.apiKeyStorageHint,
                    suffixIcon: IconButton(
                      tooltip: _obscureKey ? l10n.showKey : l10n.hideKey,
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
                  validator: (value) =>
                      _message(l10n, validateOllamaBaseUrl(value ?? '')),
                  decoration: InputDecoration(
                    labelText: l10n.serverUrl,
                    hintText: 'http://localhost:11434', // l10n-ignore: a URL
                    helperText: l10n.serverUrlHint,
                    helperMaxLines: 2,
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                autocorrect: false,
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    _message(l10n, validateModelName(value ?? '')),
                decoration: InputDecoration(
                  labelText: l10n.model,
                  helperText: models != null &&
                          _modelController.text.trim().isNotEmpty &&
                          !models
                              .any((m) => m.id == _modelController.text.trim())
                      ? l10n.modelNotListed(widget.config.displayName)
                      : null,
                  helperMaxLines: 2,
                  suffixIcon: models == null
                      ? null
                      : IconButton(
                          tooltip: l10n.chooseModel,
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () => _chooseModel(models),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _testing || _saving ? null : _testConnection,
                    icon: _testing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi_tethering),
                    label: Text(l10n.testConnection),
                  ),
                ],
              ),
              if (_tested) ...[
                const SizedBox(height: 8),
                Text(
                  _testFailure == null
                      ? l10n.connectionOk(models?.length ?? 0)
                      : l10n.aiFailure(_testFailure!, widget.config),
                  style: TextStyle(
                    color: _testFailure == null
                        ? AtomicSemanticColors.statusDone
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
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
                    : Text(l10n.save),
              ),
              const SizedBox(height: 8),
              if (_requiresKey && hasSavedKey)
                TextButton(
                  onPressed: _saving ? null : _remove,
                  child: Text(l10n.removeKey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
