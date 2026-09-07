#!/bin/bash
# --------------------------------------------------------
# Configures Brave Browser with sensible default settings
# and disables unwanted Brave features and advertisements.
# --------------------------------------------------------

if ! command -v jq >/dev/null 2>&1; then
	info "Installing 'jq' package for Brave configuration..."
	vpm install jq -y
fi

BRAVE_TEMPLATE="/root/.config/BraveSoftware/void-template"
BRAVE_PROFILE="$BRAVE_TEMPLATE/Default"

timeout 5 brave-browser-stable \
	--headless \
	--no-sandbox \
	--user-data-dir="$BRAVE_TEMPLATE" >/dev/null 2>&1 || true

PREFERENCES="$BRAVE_PROFILE/Preferences"

for ((i = 0; i < 50; i++)); do
	[[ -f "$PREFERENCES" ]] && break
	sleep 0.1
done

jq '
    .bookmark_bar.show_on_all_tabs = true |
    .bookmark_bar.show_tab_groups = false |
    .brave.location_bar_is_wide = true |
    .omnibox.prevent_url_elisions = true |
    .brave.rewards.show_brave_rewards_button_in_location_bar = false |
    .brave.wallet.show_wallet_icon_on_toolbar = false |
    .brave.new_tab_page.show_brave_news = false |
    .brave.new_tab_page.show_rewards = false |
    .brave.new_tab_page.sponsored_images.survey_panelist = false |
    .brave.ai_chat.show_toolbar_button = false |
    .brave.ai_chat.storage_enabled = false |
    .brave.ai_chat.context_menu_enabled = false |
    .brave.show_side_panel_button = false |
    .brave.brave_ads.should_allow_ads_subdivision_targeting = false
' "$PREFERENCES" >"$PREFERENCES.tmp" &&
	mv "$PREFERENCES.tmp" "$PREFERENCES"

SKEL_BRAVE="/etc/skel/.config/BraveSoftware/Brave-Browser/Default"
mkdir -p "$SKEL_BRAVE"
cp "$PREFERENCES" "$SKEL_BRAVE/Preferences"

USER_HOME="/home/$(logname)"
USER_BRAVE="$USER_HOME/.config/BraveSoftware/Brave-Browser/Default"
mkdir -p "$USER_BRAVE"
cp "$PREFERENCES" "$USER_BRAVE/Preferences"

chown -R "$(logname):$(logname)" "$USER_HOME/.config/BraveSoftware"

# Cleanup
vpm remove jq -y
rm -rf "$BRAVE_TEMPLATE"
