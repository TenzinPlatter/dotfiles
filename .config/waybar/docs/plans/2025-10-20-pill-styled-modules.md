# Waybar Pill-Styled Modules Implementation Plan

> **For Claude:** Use `${SUPERPOWERS_SKILLS_ROOT}/skills/collaboration/executing-plans/SKILL.md` to implement this plan task-by-task.

**Goal:** Transform waybar modules into individually styled pills with custom left/right end modules, making the bar background opaque between pills.

**Architecture:** Each module (or logical group) will be wrapped with custom/l-end and custom/r-end modules that provide rounded pill borders. The main waybar background remains opaque, while each pill has its own semi-transparent background with rounded borders.

**Tech Stack:** Waybar (config.jsonc), CSS styling

---

## Task 1: Create Custom End Module Definitions

**Files:**
- Modify: `/home/tenzin/.config/waybar/config.jsonc:11-13`

**Step 1: Update modules-left configuration**

Replace the current modules-left line with a pill-wrapped structure:

```json
"modules-left": [
    "custom/l-end",
    "custom/niri-workspaces",
    "custom/r-end",
    "custom/l-end",
    "custom/spotify",
    "custom/r-end"
],
```

**Expected:** Each logical module is now wrapped with l-end and r-end markers.

**Step 2: Update modules-center configuration**

Replace the current modules-center line:

```json
"modules-center": [
    "custom/l-end",
    "clock",
    "custom/r-end"
],
```

**Expected:** Clock module is wrapped in pill markers.

**Step 3: Update modules-right configuration**

Replace the current modules-right line:

```json
"modules-right": [
    "custom/l-end",
    "pulseaudio",
    "custom/r-end",
    "custom/l-end",
    "network",
    "custom/r-end",
    "custom/l-end",
    "cpu",
    "custom/r-end",
    "custom/l-end",
    "memory",
    "custom/r-end",
    "custom/l-end",
    "battery",
    "custom/r-end"
],
```

**Expected:** Each module is individually wrapped as its own pill.

**Step 4: Add custom/l-end module definition**

Add after line 20 (after custom/niri-workspaces):

```json
"custom/l-end": {
    "format": "",
    "tooltip": false
},
```

**Expected:** Left end module definition exists with empty format.

**Step 5: Add custom/r-end module definition**

Add after the custom/l-end definition:

```json
"custom/r-end": {
    "format": "",
    "tooltip": false
},
```

**Expected:** Right end module definition exists with empty format.

---

## Task 2: Update Main Waybar Window Styling

**Files:**
- Modify: `/home/tenzin/.config/waybar/style.css:8-13`

**Step 1: Make waybar background opaque**

Replace the window#waybar rule (lines 8-13) with:

```css
window#waybar {
    background-color: transparent;
    border: none;
    color: #A1BDCE;
}
```

**Expected:** The main waybar window has a transparent background with no border.

**Reasoning:** The pills will provide the visual structure, so the main window should be transparent.

---

## Task 3: Style Custom End Modules for Pill Effect

**Files:**
- Modify: `/home/tenzin/.config/waybar/style.css:15-28`

**Step 1: Remove existing module background styling**

Replace the existing modules styling block (lines 15-28) with individual modules without background:

```css
/* Remove backgrounds from individual modules - pills will provide them */
#custom-niri-workspaces,
#mpris,
#clock,
#cpu,
#memory,
#battery,
#network,
#pulseaudio,
#custom-spotify {
    padding: 0 12px;
    margin: 0;
    background-color: transparent;
    border-radius: 0;
}
```

**Expected:** Modules no longer have individual rounded backgrounds.

**Step 2: Add pill end module styling**

Add after the modules styling block (after line 28):

```css
/* Pill left end - rounded left side with background */
#custom-l-end {
    background-color: rgba(23, 23, 23, 0.8);
    border-radius: 12px 0 0 12px;
    border: 2px solid rgba(161, 189, 206, 0.2);
    border-right: none;
    padding: 0 2px;
    margin: 4px 0 4px 4px;
    min-width: 8px;
}

/* Pill right end - rounded right side with background */
#custom-r-end {
    background-color: rgba(23, 23, 23, 0.8);
    border-radius: 0 12px 12px 0;
    border: 2px solid rgba(161, 189, 206, 0.2);
    border-left: none;
    padding: 0 2px;
    margin: 4px 4px 4px 0;
    min-width: 8px;
}

/* Modules inside pills get background and borders */
#custom-niri-workspaces,
#clock,
#cpu,
#memory,
#battery,
#network,
#pulseaudio {
    background-color: rgba(23, 23, 23, 0.8);
    border-top: 2px solid rgba(161, 189, 206, 0.2);
    border-bottom: 2px solid rgba(161, 189, 206, 0.2);
    margin: 4px 0;
}
```

**Expected:** End modules create rounded pill edges, and interior modules fill the pill with consistent background and borders.

---

## Task 4: Handle Spotify Module Special Styling

**Files:**
- Modify: `/home/tenzin/.config/waybar/style.css:37-54`

**Step 1: Update spotify module styling for pills**

Replace the #custom-spotify block (lines 37-54) with:

```css
/* Spotify inside pill */
#custom-spotify {
    color: #1DB954;
    background-color: rgba(29, 185, 84, 0.15);
    border-top: 2px solid rgba(29, 185, 84, 0.3);
    border-bottom: 2px solid rgba(29, 185, 84, 0.3);
    padding: 0 12px;
    margin: 4px 0;
}

#custom-spotify.paused {
    color: #808080;
    background-color: rgba(128, 128, 128, 0.15);
    border-top: 2px solid rgba(128, 128, 128, 0.3);
    border-bottom: 2px solid rgba(128, 128, 128, 0.3);
}

#custom-spotify.stopped {
    opacity: 0;
    min-width: 0;
    padding: 0;
    margin: 0;
}
```

**Expected:** Spotify module has custom colors but follows pill structure with top/bottom borders.

**Step 2: Add special pill ends for spotify**

Add after the spotify module styling:

```css
/* Spotify pill ends - use spotify color theme */
#custom-l-end + #custom-spotify ~ #custom-r-end {
    background-color: rgba(29, 185, 84, 0.15);
    border-color: rgba(29, 185, 84, 0.3);
}

/* Adjacent l-end before spotify */
#custom-spotify:not(.stopped) ~ #custom-l-end {
    background-color: rgba(29, 185, 84, 0.15);
    border-color: rgba(29, 185, 84, 0.3);
}
```

**Note:** This is an approximate selector. CSS limitations may require testing and adjustment.

**Expected:** Spotify pill ends match the spotify theme colors.

---

## Task 5: Test and Verify Configuration

**Files:**
- Read: `/home/tenzin/.config/waybar/config.jsonc`
- Read: `/home/tenzin/.config/waybar/style.css`

**Step 1: Validate JSON syntax**

Run: `jq empty /home/tenzin/.config/waybar/config.jsonc`

**Expected:** No output (valid JSON) or specific error message if invalid.

**Step 2: Reload waybar to see changes**

Run: `killall waybar && waybar &`

**Expected:** Waybar reloads with new pill-styled modules. Each module appears in its own rounded pill with opaque spacing between pills.

**Step 3: Visual verification checklist**

Verify:
- [ ] Each module is in its own pill with rounded left and right edges
- [ ] Space between pills is transparent (shows desktop/wallpaper)
- [ ] Pills have semi-transparent backgrounds
- [ ] All modules are visible and properly formatted
- [ ] Clock is centered and in its own pill
- [ ] Spotify module (if playing) has green-tinted pill
- [ ] No visual glitches or overlapping borders

**Step 4: Fine-tune spacing if needed**

If pills are too close or too far apart, adjust in `/home/tenzin/.config/waybar/config.jsonc`:

```json
"spacing": 8,  // Increase for more space between pills
```

**Expected:** Comfortable visual spacing between pills.

---

## Task 6: Handle Edge Cases

**Files:**
- Modify: `/home/tenzin/.config/waybar/style.css` (append)

**Step 1: Add hover effects for pills (optional enhancement)**

Add at end of style.css:

```css
/* Optional: Hover effects for interactive pills */
#pulseaudio:hover,
#network:hover,
#battery:hover {
    background-color: rgba(23, 23, 23, 0.95);
    transition: background-color 0.2s ease;
}
```

**Expected:** Interactive modules slightly change background on hover.

**Step 2: Handle dynamic spotify visibility**

Ensure the spotify pill completely disappears when stopped:

```css
/* Hide spotify pill ends when spotify is stopped */
.stopped ~ #custom-r-end,
#custom-l-end:has(+ .stopped) {
    opacity: 0;
    min-width: 0;
    padding: 0;
    margin: 0;
}
```

**Note:** The `:has()` selector may not work in all waybar versions. Test and remove if causing issues.

**Expected:** When spotify is stopped, its entire pill (including ends) disappears.

---

## Implementation Notes

**DRY Principles:**
- Custom l-end and r-end modules are reusable for any module
- Single definition in config, styled once in CSS
- Easy to add new pills by wrapping any module

**YAGNI:**
- No complex nesting or unnecessary wrapper divs
- Simple CSS selectors focusing on direct styling
- No JavaScript or dynamic generation

**Testing:**
- After each task, check waybar reloads without errors
- Visual verification that pills render correctly
- Config validation using jq

**Commit Strategy:**
- Commit after Task 1 (config changes)
- Commit after Task 2-3 (basic styling)
- Commit after Task 4 (spotify special styling)
- Commit after Task 5 (working configuration)
- Commit after Task 6 (enhancements)

---

## Alternative Design Considerations

**Single Pill per Section:**
If you prefer grouping (e.g., all right modules in one pill), modify Task 1 to:

```json
"modules-right": [
    "custom/l-end",
    "pulseaudio",
    "network",
    "cpu",
    "memory",
    "battery",
    "custom/r-end"
],
```

**Variable Pill Colors:**
Each module can have its own pill color by targeting specific module combinations with adjacent sibling selectors or by creating named end modules like `custom/l-end-cpu`, `custom/r-end-cpu`, etc.

**Border vs No Border:**
Current plan includes subtle borders. To remove, set `border: none;` in the l-end and r-end rules.

---

## Execution Complete

All tasks defined with exact file paths, code blocks, commands, and expected outcomes. Engineer can execute this plan with zero codebase context.
