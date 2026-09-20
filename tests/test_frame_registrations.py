from pathlib import Path
import unittest

from lupa.lua51 import LuaRuntime


FRAMES_PATH = Path(__file__).parents[1] / "Frames.lua"


class FrameRegistrationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        runtime = LuaRuntime(unpack_returned_tuples=True)
        runtime.execute(
            """
            capturedFrames = nil
            capturedAddOnFrames = nil
            BlizzMoveAPI = {
                Versions = {
                    Forever = "Forever", Standard = "Standard", Midnight = "Midnight",
                    TWW = "TWW", DF = "DF", SL = "SL", BFA = "BFA",
                    Legion = "Legion", WOD = "WOD", MOP = "MOP", Cata = "Cata",
                    Wrath = "Wrath", TBC = "TBC", Vanilla = "Vanilla",
                    Mainline = "Mainline", Classic = "Classic", Fallback = "Fallback",
                },
                RegisterFrames = function(_, frames) capturedFrames = frames end,
                RegisterAddOnFrames = function(_, frames) capturedAddOnFrames = frames end,
            }

            BlizzMove = {Versions=BlizzMoveAPI.Versions}
            """
        )
        core = (FRAMES_PATH.parent / "BlizzMove.lua").read_text(encoding="utf-8")
        start = core.index("    local function checkRanges(ranges, needle)")
        end = core.index("    function BlizzMove:CopyTable(table)", start)
        runtime.execute(core[start:end])
        runtime.execute(FRAMES_PATH.read_text(encoding="utf-8"))
        cls.runtime = runtime
        cls.addon_frames = runtime.globals().capturedAddOnFrames

    def matches(self, frame_data, version, game_type, family, interface):
        addon = self.runtime.globals().BlizzMove
        addon.gameVersion = version
        addon.gameType = game_type
        addon.gameFamily = family
        addon.interfaceVersion = interface
        return addon.MatchesCurrentBuild(addon, frame_data, "test-frame")

    def test_forever_only_registration_is_present(self):
        legacy = self.addon_frames["Blizzard_LegacySystem"]["LegacySystemFrame"]

        self.assertTrue(legacy["Versions"]["Forever"])

    def test_forever_legacy_system_does_not_register_for_classic(self):
        legacy = self.addon_frames["Blizzard_LegacySystem"]["LegacySystemFrame"]

        self.assertFalse(self.matches(legacy, "Vanilla", "Vanilla", "Classic", 11500))

    def test_forever_uses_the_current_achievement_name_and_no_standalone_professions_book(self):
        achievement_ui = self.addon_frames["Blizzard_AchievementUI"]
        search_results = achievement_ui["AchievementFrame.SearchResults"]
        professions_book = self.addon_frames["Blizzard_ProfessionsBook"]["ProfessionsBookFrame"]

        self.assertIsNone(achievement_ui["AchievementFrame.searchResults"])
        self.assertTrue(self.matches(search_results, "Forever", "Forever", "Mainline", 16001))
        self.assertTrue(self.matches(professions_book, "Midnight", "Standard", "Mainline", 120000))
        self.assertFalse(self.matches(professions_book, "Forever", "Forever", "Mainline", 16001))
        self.assertFalse(self.matches(professions_book, "Vanilla", "Vanilla", "Classic", 11500))


if __name__ == "__main__":
    unittest.main()
