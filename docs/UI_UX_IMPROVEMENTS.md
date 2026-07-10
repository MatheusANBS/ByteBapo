# ByteBapo UI/UX Improvement Specifications

**Document Version:** 1.0  
**Created:** 2026-07-10  
**Status:** Proposal  

---

## Executive Summary

This document outlines comprehensive UI/UX improvements for the ByteBapo Flutter application. The app is a Material 3 dark-themed chat client for Ollama (LAN) and NVIDIA API. While functional, several areas need refinement for better usability, accessibility, and visual polish.

---

## 1. Visual Hierarchy & Spacing

### 1.1 Current Issues
- Inconsistent padding values across screens (8, 10, 12, 14, 16, 20, 24, 88)
- Tight vertical spacing reduces readability
- Non-standard AppBar height (52px vs Material default 56/64)

### 1.2 Specifications

**SPEC-1.1: Spacing System**
```dart
// Implement 4px base grid system
const kSpacingUnit = 4.0;
const kSpacingXS = 4.0;   // 1 unit
const kSpacingSM = 8.0;   // 2 units
const kSpacingMD = 12.0;  // 3 units
const kSpacingLG = 16.0;  // 4 units
const kSpacingXL = 20.0;  // 5 units
const kSpacingXXL = 24.0; // 6 units
```

**SPEC-1.2: Standardized Padding**
- Screen padding: `EdgeInsets.fromLTRB(16, 8, 16, 16)`
- List items: `EdgeInsets.symmetric(horizontal: 12, vertical: 8)`
- Card content: `EdgeInsets.all(16)`
- Dialog content: `EdgeInsets.fromLTRB(24, 20, 24, 24)`

**SPEC-1.3: AppBar Standardization**
```dart
// Use Material 3 default toolbar height (56dp compact, 64dp default)
appBarTheme: AppBarTheme(
  toolbarHeight: 56, // or omit for default
  elevation: 0,
  scrolledUnderElevation: 2,
)
```

### 1.3 Implementation Plan
1. Create `lib/app/spacing.dart` with spacing constants
2. Update theme.dart with standardized AppBar
3. Refactor all screens to use spacing constants
4. Test on multiple screen sizes

**Priority:** High  
**Effort:** Medium (4-6 hours)

---

## 2. Color & Contrast

### 2.1 Current Issues
- Low contrast text (alpha 0.74, 0.78) fails WCAG AA
- Surface colors too similar for clear depth perception
- Primary color needs colorblind accessibility testing

### 2.2 Specifications

**SPEC-2.1: Minimum Contrast Ratios**
- Body text: WCAG AA (4.5:1 minimum)
- Large text (18px+): WCAG AA (3:1 minimum)
- Interactive elements: 3:1 minimum against background

**SPEC-2.2: Updated Color Scheme**
```dart
final scheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2DD4BF),
  brightness: Brightness.dark,
  surface: const Color(0xFF0F1419),    // Darker for contrast
  onSurface: const Color(0xFFE8ECEF),   // Higher contrast text
  surfaceContainerHighest: const Color(0xFF1E252B), // More contrast
);
```

**SPEC-2.3: Text Opacity Guidelines**
- Primary text: 1.0 (no opacity reduction)
- Secondary text: 0.85 minimum
- Disabled text: 0.60
- Avoid alpha blending for critical content

### 2.3 Implementation Plan
1. Audit all text widgets for contrast compliance
2. Update theme.dart with improved color scheme
3. Replace `.withValues(alpha: X)` patterns with semantic colors
4. Test with ChromeVox and Android TalkBack

**Priority:** High  
**Effort:** Medium (3-4 hours)

---

## 3. Touch Targets & Interactions

### 3.1 Current Issues
- CharacterAvatar radius 12px = 24px diameter (below 48px minimum)
- Icon buttons with 18px icons lack proper touch area
- `_CompactDropdown` height 36px is too small

### 3.2 Specifications

**SPEC-3.1: Minimum Touch Target**
```dart
const kMinTouchTarget = 48.0; // Android/IOS guideline

// For small visual elements, wrap with touch target
SizedBox(
  width: kMinTouchTarget,
  height: kMinTouchTarget,
  child: Center(child: Icon(...)),
)
```

**SPEC-3.2: Icon Button Standards**
```dart
// Use built-in IconButton for 48x48 touch target
IconButton(
  icon: Icon(Icons.close, size: 24), // 24px icon, 48px tap area
  onPressed: () {},
)

// For custom buttons, ensure minimum size
SizedBox.square(
  dimension: 48,
  child: InkWell(onTap: () {}, child: ...),
)
```

**SPEC-3.3: Dropdown Minimum Height**
```dart
// Increase _CompactDropdown height
Container(
  height: 48, // was 36
  // ...
)
```

**SPEC-3.4: Character Selector**
```dart
// Increase avatar touch target
InkWell(
  onTap: () => _showPicker(context),
  child: SizedBox(
    width: 48,
    height: 48,
    child: Center(
      child: CharacterAvatar(radius: 16), // visual size
    ),
  ),
)
```

### 3.3 Implementation Plan
1. Audit all interactive elements for touch target compliance
2. Update `_CompactDropdown` height to 48px
3. Wrap small avatars/icons with proper touch targets
4. Add `TapTargetSize` consideration in theme

**Priority:** High  
**Effort:** Medium (3-5 hours)

---

## 4. Navigation & Information Architecture

### 4.1 Current Issues
- Inconsistent back navigation patterns
- No breadcrumbs or location indicators
- Popup menus lack visual hierarchy
- Deep linking not configured

### 4.2 Specifications

**SPEC-4.1: Consistent Navigation Pattern**
```dart
// All screens should have consistent back button behavior
AppBar(
  automaticallyImplyLeading: true, // default back button
  title: Text(screenTitle),
  actions: [...],
)
```

**SPEC-4.2: Breadcrumb Implementation**
```dart
// Add subtle breadcrumb in AppBar subtitle
AppBar(
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Chat'),
      Text(
        'Servidor · Modelo · Personagem',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  ),
)
```

**SPEC-4.3: Popup Menu Improvements**
```dart
// Add dividers and group related actions
PopupMenuButton<_ChatMenuAction>(
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: _ChatMenuAction.history,
      child: ListTile(
        leading: Icon(Icons.history),
        title: Text('Histórico'),
      ),
    ),
    const PopupMenuDivider(), // Add divider
    const PopupMenuItem(
      value: _ChatMenuAction.clear,
      child: ListTile(
        leading: Icon(Icons.delete_outline, color: Colors.red),
        title: Text('Limpar', style: TextStyle(color: Colors.red)),
      ),
    ),
  ],
)
```

**SPEC-4.4: Deep Linking Setup**
```dart
// Configure go_router for deep links
final _router = GoRouter(
  initialLocation: '/chat',
  routes: [
    GoRoute(path: '/chat', builder: ...),
    GoRoute(path: '/chat/:conversationId', builder: ...),
    GoRoute(path: '/servers', builder: ...),
    // ...
  ],
)
```

### 4.3 Implementation Plan
1. Audit navigation patterns across all screens
2. Add breadcrumbs to chat screen (already partially implemented)
3. Improve popup menu visual hierarchy
4. Configure deep linking in router

**Priority:** Medium  
**Effort:** Medium (4-6 hours)

---

## 5. Feedback & States

### 5.1 Current Issues
- Basic loading indicators only
- Generic error messages without retry options
- Empty states lack clear CTAs
- Success feedback is subtle text only

### 5.2 Specifications

**SPEC-5.1: Skeleton Loaders**
```dart
// Replace CircularProgressIndicator with skeleton for lists
ListView.builder(
  itemCount: 5,
  itemBuilder: (context, index) => Shimmer.fromColors(
    baseColor: Colors.grey[850]!,
    highlightColor: Colors.grey[800]!,
    child: ListTile(
      leading: CircleAvatar(radius: 20),
      title: Container(
        height: 16,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  ),
)
```

**SPEC-5.2: Error Handling with Retry**
```dart
// Replace generic error text with actionable UI
Center(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
        const SizedBox(height: 16),
        Text(
          'Não foi possível carregar os modelos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Verifique sua conexão e tente novamente',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => ref.invalidate(modelsProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar Novamente'),
        ),
      ],
    ),
  ),
)
```

**SPEC-5.3: Success Feedback**
```dart
// Replace _feedback text with SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Servidor salvo e selecionado.'),
    action: SnackBarAction(
      label: 'Desfazer',
      onPressed: () { /* undo logic */ },
    ),
    duration: const Duration(seconds: 2),
  ),
);
```

**SPEC-5.4: Empty State Improvements**
```dart
// Enhanced empty state with illustration and CTA
Center(
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/empty_chat.svg',
          height: 120,
          width: 120,
        ),
        const SizedBox(height: 24),
        Text(
          'Nenhuma conversa ainda',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Suas conversas salvas aparecerão aqui.\nComece uma nova conversa!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => context.go('/chat'),
          icon: const Icon(Icons.add),
          label: const Text('Nova Conversa'),
        ),
      ],
    ),
  ),
)
```

### 5.3 Implementation Plan
1. Add `shimmer` package to pubspec.yaml
2. Create skeleton loader widgets
3. Refactor error states with retry buttons
4. Convert _feedback to SnackBar pattern
5. Design and add empty state illustrations

**Priority:** High  
**Effort:** High (8-12 hours)

---

## 6. Chat-Specific Improvements

### 6.1 Current Issues
- No visual distinction for system/tool messages
- Thinking mode could have better indicators
- Manual scroll logic doesn't respect user scroll position
- Code blocks lack syntax highlighting
- Copy only works on last message

### 6.2 Specifications

**SPEC-6.1: Message Type Styling**
```dart
// Different colors for different message roles
Color _bubbleColor(ChatRole role) {
  return switch (role) {
    ChatRole.user => 
      Theme.of(context).colorScheme.primaryContainer,
    ChatRole.assistant => 
      Theme.of(context).colorScheme.surfaceContainerHighest,
    ChatRole.system => 
      Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.5),
    ChatRole.tool => 
      Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.6),
  };
}
```

**SPEC-6.2: Smart Scroll Behavior**
```dart
// Only auto-scroll if user is near bottom
bool _isNearBottom() {
  if (!_scrollController.hasClients) return false;
  final maxScroll = _scrollController.position.maxScrollExtent;
  final currentScroll = _scrollController.position.pixels;
  return (maxScroll - currentScroll) < 200; // 200px threshold
}

void _scrollToEnd({required bool animate}) {
  if (!_isNearBottom()) return; // Don't interrupt user reading
  // ... scroll logic
}
```

**SPEC-6.3: Copy All Functionality**
```dart
// Add "Copy All" to chat menu
PopupMenuButton<_ChatMenuAction>(
  onSelected: (action) {
    if (action == _ChatMenuAction.copyAll) {
      final allText = controller.messages
          .map((m) => '${m.isAssistant ? 'AI' : 'Você'}: ${m.content}')
          .join('\n\n');
      Clipboard.setData(ClipboardData(text: allText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversa copiada!')),
      );
    }
  },
  // ...
)
```

**SPEC-6.4: Thinking Mode Indicator**
```dart
// Add visual badge when thinking content available
if (message.thinking.isNotEmpty)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.psychology, size: 14),
        const SizedBox(width: 4),
        Text('Thinking', style: TextStyle(fontSize: 11)),
      ],
    ),
  )
```

### 6.3 Implementation Plan
1. Add system/tool message styling
2. Implement smart scroll detection
3. Add "Copy All" to chat menu
4. Enhance thinking mode visual indicator
5. Consider adding `highlight` package for code syntax

**Priority:** Medium  
**Effort:** Medium (5-7 hours)

---

## 7. Forms & Inputs

### 7.1 Current Issues
- Server form has many fields without organization
- No real-time validation feedback
- API Key field lacks show/hide toggle
- Protocol selector could be more intuitive

### 7.2 Specifications

**SPEC-7.1: Form Grouping**
```dart
// Group form fields into sections
ExpansionTile(
  leading: Icon(Icons.dns_outlined),
  title: Text('Configurações Básicas'),
  initiallyExpanded: true,
  children: [
    // Name, Host, Port fields
  ],
),
ExpansionTile(
  leading: Icon(Icons.settings_outlined),
  title: Text('Configurações Avançadas'),
  children: [
    // Base path, Headers, API Key fields
  ],
)
```

**SPEC-7.2: Real-time Validation**
```dart
// Add autovalidateMode for instant feedback
TextFormField(
  controller: _hostController,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o host';
    }
    if (!isValidHost(value.trim())) {
      return 'Host inválido';
    }
    return null;
  },
)
```

**SPEC-7.3: API Key Visibility Toggle**
```dart
// Add show/hide password functionality
StatefulWidget with _obscureText = true
TextFormField(
  controller: _apiKeyController,
  obscureText: _obscureText,
  suffixIcon: IconButton(
    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
    onPressed: () => setState(() => _obscureText = !_obscureText),
  ),
)
```

**SPEC-7.4: Inline Protocol Selector**
```dart
// Move protocol into host field as prefix
Row(
  children: [
    DropdownButton<String>(
      value: _protocol,
      items: ['http', 'https'].map((p) => 
        DropdownMenuItem(value: p, child: Text(p))
      ).toList(),
      onChanged: (v) => setState(() => _protocol = v!),
    ),
    const Text('://'),
    Expanded(
      child: TextFormField(
        controller: _hostController,
        decoration: InputDecoration(labelText: 'Host ou IP'),
      ),
    ),
  ],
)
```

### 7.3 Implementation Plan
1. Refactor server form with expansion tiles
2. Add autovalidateMode to all form fields
3. Implement show/hide for API key field
4. Redesign protocol selector as inline dropdown

**Priority:** Medium  
**Effort:** Medium (4-6 hours)

---

## 8. Lists & Content

### 8.1 Current Issues
- Global dense ListTile reduces readability
- PopupMenu hides primary actions
- "Usar" button label unclear

### 8.2 Specifications

**SPEC-8.1: List Density**
```dart
// Remove global dense setting, use per-context
listTileTheme: ListTileThemeData(
  dense: false, // was true
  minLeadingWidth: 48,
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
)
```

**SPEC-8.2: Inline Action Buttons**
```dart
// Replace PopupMenu with inline buttons for common actions
ListTile(
  title: Text(conversation.title),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.open_in_new),
        tooltip: 'Abrir',
        onPressed: () => context.go('/chat?conversation=${conversation.id}'),
      ),
      IconButton(
        icon: Icon(Icons.delete_outline),
        tooltip: 'Excluir',
        onPressed: () => _delete(conversation.id),
      ),
    ],
  ),
)
```

**SPEC-8.3: Clear Button Labels**
```dart
// Change "Usar" to "Selecionar" or "Definir como ativo"
FilledButton(
  onPressed: () async {
    await ref.read(modelSelectionRepositoryProvider)
        .setSelectedModel(modelId, serverProfileId: activeServer.id);
    // ...
  },
  child: const Text('Selecionar'), // was 'Usar'
)
```

### 8.3 Implementation Plan
1. Update ListTile theme density
2. Replace PopupMenu with inline buttons where appropriate
3. Update button labels for clarity
4. Test list scrolling performance

**Priority:** Medium  
**Effort:** Low-Medium (2-4 hours)

---

## 9. Typography

### 9.1 Current Issues
- Hardcoded font sizes (12, 18) instead of TextTheme
- Inconsistent line heights
- Excessive truncation with maxLines: 1

### 9.2 Specifications

**SPEC-9.1: TextTheme Usage**
```dart
// Replace hardcoded sizes with TextTheme
Text(
  'Title',
  style: Theme.of(context).textTheme.titleMedium, // instead of fontSize: 18
)

// Define custom text theme if needed
textTheme: TextTheme(
  bodySmall: TextStyle(fontSize: 13, height: 1.4),
  bodyMedium: TextStyle(fontSize: 15, height: 1.4),
  titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
)
```

**SPEC-9.2: Truncation Guidelines**
```dart
// Allow 2 lines for better readability
Text(
  character.instructions,
  maxLines: 2, // was 1
  overflow: TextOverflow.ellipsis,
)
```

### 9.3 Implementation Plan
1. Audit all Text widgets for hardcoded sizes
2. Replace with TextTheme references
3. Increase maxLines from 1 to 2 where appropriate
4. Test with different font sizes (accessibility)

**Priority:** Low  
**Effort:** Medium (3-5 hours)

---

## 10. Accessibility

### 10.1 Current Issues
- Missing semantic labels on icon buttons
- No ScreenReader support for custom components
- Unclear focus order
- Untested with large font sizes

### 10.2 Specifications

**SPEC-10.1: Semantic Labels**
```dart
// Add tooltips and semantics to all icon-only buttons
IconButton(
  tooltip: 'Copiar mensagem', // Required for screen readers
  icon: const Icon(Icons.copy),
  onPressed: () => Clipboard.setData(...),
)

// For custom widgets
Semantics(
  label: 'Carregando personagem ${character.name}',
  child: _PersonaLoadingIndicator(character: character),
)
```

**SPEC-10.2: Focus Order**
```dart
// Use FocusTraversalGroup for logical focus order
FocusTraversalGroup(
  policy: WidgetOrderTraversalPolicy(),
  child: Column(
    children: [
      TextField(focusNode: _nameNode),
      TextField(focusNode: _emailNode),
      ElevatedButton(onPressed: _submit),
    ],
  ),
)
```

**SPEC-10.3: Large Font Testing**
```dart
// Test with Android font scale up to 2.0
// Ensure no overflow or layout breaks
MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaleFactor: 2.0),
  child: MyWidget(),
)
```

### 10.3 Implementation Plan
1. Add tooltips to all IconButton widgets
2. Wrap custom components with Semantics
3. Test with TalkBack and ChromeVox
4. Test with font sizes up to 2.0x
5. Document accessibility features

**Priority:** High  
**Effort:** Medium (4-6 hours)

---

## 11. Performance UX

### 11.1 Current Issues
- Image loading without caching or indicators
- Multiple provider invalidations may cause jank

### 11.2 Specifications

**SPEC-11.1: Image Caching**
```dart
// Add cached_network_image package for avatar caching
dependencies:
  cached_network_image: ^3.3.0

// Use in CharacterAvatar
CachedNetworkImage(
  imageUrl: character.imagePath,
  imageBuilder: (context, imageProvider) => CircleAvatar(
    backgroundImage: imageProvider,
    radius: radius,
  ),
  placeholder: (context, url) => CircleAvatar(
    radius: radius,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
  errorWidget: (context, url, error) => CircleAvatar(
    radius: radius,
    child: Icon(Icons.person, size: radius),
  ),
)
```

**SPEC-11.2: Batched Provider Updates**
```dart
// Batch invalidations to reduce rebuilds
ref.listen<AsyncValue>(someProvider, (previous, next) {
  next.whenOrNull(
    data: (_) {
      // Invalidate multiple providers at once
      ref.invalidate(serverProfilesProvider);
      ref.invalidate(activeServerProvider);
      ref.invalidate(modelsProvider);
    },
  );
});
```

### 11.3 Implementation Plan
1. Add cached_network_image to dependencies
2. Update CharacterAvatar to use caching
3. Review provider invalidation patterns
4. Add Flutter DevTools performance testing

**Priority:** Low  
**Effort:** Low (2-3 hours)

---

## 12. Quick Wins Summary

### 12.1 Immediate Improvements (< 1 hour each)

| ID | Improvement | File(s) | Impact |
|----|-------------|---------|--------|
| QW-1 | Increase border radius to 12px | theme.dart | Visual polish |
| QW-2 | Add haptic feedback on send | chat_screen.dart | Tactile feedback |
| QW-3 | Increase divider opacity to 0.20 | theme.dart | Better visibility |
| QW-4 | Add tooltips to all IconButtons | All screens | Accessibility |
| QW-5 | Replace _feedback with SnackBar | All screens | Better UX |

### 12.2 Code Snippets

**QW-1: Consistent Border Radius**
```dart
// theme.dart
inputDecorationTheme: InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12), // was 8
  ),
)
```

**QW-2: Haptic Feedback**
```dart
// chat_screen.dart
onSubmitted: () async {
  await HapticFeedback.lightImpact();
  // ... send logic
}
```

**QW-3: Better Divider Contrast**
```dart
// theme.dart
border: Border.all(
  color: outline.withValues(alpha: 0.20), // was 0.10-0.16
)
```

---

## Implementation Roadmap

### Phase 1: Critical (Week 1-2)
- [ ] SPEC-3: Touch targets (High priority, accessibility)
- [ ] SPEC-2: Color contrast (High priority, accessibility)
- [ ] SPEC-5: Feedback & states (High priority, usability)
- [ ] SPEC-10: Accessibility labels (High priority, compliance)

### Phase 2: Core Improvements (Week 3-4)
- [ ] SPEC-1: Spacing system (Medium priority, consistency)
- [ ] SPEC-6: Chat improvements (Medium priority, core feature)
- [ ] SPEC-7: Forms & inputs (Medium priority, key flow)
- [ ] SPEC-4: Navigation (Medium priority, UX)

### Phase 3: Polish (Week 5-6)
- [ ] SPEC-8: Lists & content (Medium priority)
- [ ] SPEC-9: Typography (Low priority)
- [ ] SPEC-11: Performance (Low priority)
- [ ] SPEC-12: Quick wins (Ongoing)

---

## Testing & Validation

### 12.1 Accessibility Testing
- [ ] Run Flutter accessibility inspector
- [ ] Test with Android TalkBack
- [ ] Test with large font sizes (up to 2.0x)
- [ ] Verify color contrast ratios (WCAG AA)

### 12.2 Usability Testing
- [ ] Test on multiple screen sizes (phone, tablet)
- [ ] Test with 5+ users for feedback
- [ ] Measure task completion time
- [ ] Collect SUS (System Usability Scale) scores

### 12.3 Performance Testing
- [ ] Run Flutter DevTools
- [ ] Check for jank (frame drops)
- [ ] Monitor memory usage
- [ ] Test on low-end devices

---

## Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Lighthouse Accessibility | N/A | 90+ | Manual audit |
| Task Completion Rate | N/A | 95%+ | User testing |
| Time to First Message | N/A | < 30s | Analytics |
| Crash-free Sessions | N/A | 99%+ | Firebase |
| User Satisfaction (SUS) | N/A | 75+ | Survey |

---

## Appendix A: Related Documentation

- [Material 3 Design Guidelines](https://m3.material.io/)
- [Flutter Accessibility](https://docs.flutter.dev/development/ui/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Android Touch Targets](https://developer.android.com/guide/topics/ui/accessibility/touch-targets)

---

## Appendix B: Package Recommendations

```yaml
dependencies:
  shimmer: ^3.0.0          # Skeleton loaders
  cached_network_image: ^3.3.0  # Image caching
  flutter_svg: ^2.0.0      # SVG illustrations
  highlight: ^0.7.0        # Code syntax highlighting

dev_dependencies:
  flutter_test:            # Widget testing
  integration_test:        # E2E testing
```

---

**End of Document**