{
  programs.zen-browser = {
    enable = true;
    languagePacks = [ "en-US" ];
    setAsDefaultBrowser = true;
    enablePrivateDesktopEntry = true;

    policies =
      let
        mkLockedAttrs = builtins.mapAttrs (
          _: value: {
            Value = value;
            Status = "locked";
          }
        );

        mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

        mkExtensionEntry =
          {
            id,
            pinned ? false,
          }:
          let
            base = {
              install_url = mkPluginUrl id;
              installation_mode = "force_installed";
            };
          in
          if pinned then base // { default_area = "navbar"; } else base;

        mkExtensionSettings = builtins.mapAttrs (
          _: entry: if builtins.isAttrs entry then entry else mkExtensionEntry { id = entry; }
        );
      in
      {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true; # save webs for later reading
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        SanitizeOnShutdown = {
          FormData = true;
          Cache = true;
        };
        ExtensionSettings = mkExtensionSettings {
          "uBlock0@raymondhill.net" = mkExtensionEntry {
            id = "ublock-origin";
            pinned = true;
          };
          "keepassxc-browser@keepassxc.org" = mkExtensionEntry {
            id = "keepassxc-browser";
            pinned = true;
          };
          "addon@darkreader.org" = mkExtensionEntry {
            id = "darkreader";
            pinned = true;
          };
          "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = "refined-github-";
          "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = "github-file-icons";
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
          "github-no-more@ihatereality.space" = "github-no-more";
          "github-repository-size@pranavmangal" = "gh-repo-size";
          "firefox-extension@steamdb.info" = "steam-database";
          "@searchengineadremover" = "searchengineadremover";
          "jid1-BoFifL9Vbdl2zQ@jetpack" = "decentraleyes";
          "trackmenot@mrl.nyu.edu" = "trackmenot";
          "{861a3982-bb3b-49c6-bc17-4f50de104da1}" = "custom-user-agent-revived";
        };
        Preferences = mkLockedAttrs {
          "browser.aboutConfig.showWarning" = false;
          "browser.tabs.warnOnClose" = false;
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
          # Disable swipe gestures (Browser:BackOrBackDuplicate, Browser:ForwardOrForwardDuplicate)
          "browser.gesture.swipe.left" = "";
          "browser.gesture.swipe.right" = "";
          "browser.tabs.hoverPreview.enabled" = true;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.topsites.contile.enabled" = false;

          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
          "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
          "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
          "privacy.resistFingerprinting.block_mozAddonManager" = true;
          "privacy.spoof_english" = 1;

          "privacy.firstparty.isolate" = true;
          "network.cookie.cookieBehavior" = 5;
          "dom.battery.enabled" = false;

          "gfx.webrender.all" = true;
          "network.http.http3.enabled" = true;
          "network.socket.ip_addr_any.disabled" = true; # disallow bind to 0.0.0.0
        };
      };

    profiles.default = {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "full-screen-api.ignore-widgets" = true;
        "zen.welcome-screen.seen" = true;
      };

      mods = [
        "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
        "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
        "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
        "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scrollbar
        "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
        "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
      ];

      keyboardShortcutsVersion = 17;
      keyboardShortcuts = [
        {
          id = "zen-compact-mode-toggle";
          key = "c";
          modifiers.alt = true;
        }
        {
          id = "zen-toggle-sidebar";
          key = "s";
          modifiers.alt = true;
        }
        {
          id = "zen-close-all-unpinned-tabs";
          disabled = true;
        }
        {
          id = "zen-workspace-backward";
          key = "[";
          modifiers.alt = true;
        }
        {
          id = "zen-workspace-forward";
          key = "]";
          modifiers.alt = true;
        }
        {
          id = "zen-new-empty-split-view";
          disabled = true;
        }
        {
          id = "zen-split-view-unsplit";
          key = "q";
          modifiers.alt = true;
        }
        {
          id = "zen-split-view-horizontal";
          key = "h";
          modifiers.alt = true;
        }
        {
          id = "zen-split-view-vertical";
          key = "v";
          modifiers.alt = true;
        }
        {
          id = "zen-split-view-grid";
          disabled = true;
        }
        {
          id = "zen-new-unsynced-window";
          disabled = true;
        }
        {
          id = "zen-glance-expand";
          disabled = true;
        }
        {
          id = "zen-toggle-pin-tab";
          disabled = true;
        }
        {
          id = "zen-copy-url-markdown";
          disabled = true;
        }
        {
          id = "key_closeWindow";
          disabled = true;
        }
        {
          id = "key_quitApplication";
          disabled = true;
        }
        {
          id = "goBackKb2";
          disabled = true;
        }
        {
          id = "goForwardkKb2";
          disabled = true;
        }
        {
          id = "goHome";
          disabled = true;
        }
        {
          id = "key_search";
          disabled = true;
        }
        {
          id = "key_search2";
          disabled = true;
        }
        {
          id = "key_findAgain";
          disabled = true;
        }
        {
          id = "key_findPrevious";
          disabled = true;
        }
        {
          id = "focusURLBar2";
          disabled = true;
        }
        {
          id = "key_savePage";
          disabled = true;
        }
        {
          id = "key_togglePictureInPicture";
          disabled = true;
        }
        {
          id = "key_viewSource";
          disabled = true;
        }
        {
          id = "key_viewInfo";
          disabled = true;
        }
        {
          id = "key_switchTextDirection";
          disabled = true;
        }
      ];

      search = {
        force = true;
        default = "brave";
        engines = {
          brave = {
            name = "Brave Search";
            urls = [
              {
                template = "https://search.brave.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = [ "brave" ];
          };
        };
      };
    };
  };
}
