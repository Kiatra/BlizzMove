"""Portable config callback and Lua 5.1 syntax checks.

Author: Neil Mitchell
Last Modified By: Neil Mitchell
"""

from pathlib import Path
import unittest

from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]


class ConfigAndSyntax(unittest.TestCase):
    def test_all_project_lua_compiles(self):
        lua = LuaRuntime(unpack_returned_tuples=True)
        compile_only = lua.eval("function(s, n) local f,e=loadstring(s,n); assert(f,e) end")
        paths = [p for p in ROOT.rglob("*.lua") if "Libs" not in p.relative_to(ROOT).parts]
        self.assertTrue(paths)
        for path in paths:
            with self.subTest(path=str(path.relative_to(ROOT))):
                compile_only(path.read_text(encoding="utf-8-sig"), str(path.relative_to(ROOT)))

    def test_original_links_and_forever_credit_callback(self):
        for version in ("Forever", "Standard", "Vanilla"):
            with self.subTest(version=version):
                lua = LuaRuntime(unpack_returned_tuples=True)
                lua.execute("""
                    addon = {Versions={Forever='Forever'}}
                    C_AddOns={GetAddOnMetadata=function() return 'test' end}
                    C_UI={Reload=function() end}
                    StaticPopupDialogs={}
                    function StaticPopup_Show(id, a, b, data) popup={id=id,data=data} end
                    function LibStub() return {GetAddon=function() return addon end} end
                    function CreateAtlasMarkup() return 'mouse' end
                    function CreateCounter() local n=0; return function() n=n+1; return n end end
                    ns={L=setmetatable({}, {__index=function(_,k) return k end})}
                """)
                lua.globals().addon.gameVersion = version
                source = (ROOT / "BlizzMoveConfig.lua").read_text(encoding="utf-8")
                lua.execute("assert(loadstring(...))('BlizzMove', ns)", source)
                options = lua.eval("addon.Config:GetOptions().args.mainTab.args")
                self.assertEqual(options.lauButton.hidden, version != "Forever")
                self.assertEqual(options.lauButton.name, "Lau [WoW Forever edits]")
                self.assertGreater(options.lauButton.order, options.numyButton.order)
                for key, url in (
                    ("kiatraButton", "https://www.paypal.com/cgi-bin/webscr?hosted_button_id=FF9F9GTXMG392&item_name=BlizzMove&cmd=_s-xclick"),
                    ("numyButton", "https://www.paypal.com/cgi-bin/webscr?hosted_button_id=C8HP9WVKPCL8C&item_name=BlizzMove&cmd=_s-xclick"),
                    ("lauButton", "https://streamlabs.com/lausudo/tip"),
                ):
                    options[key].func()
                    self.assertEqual(lua.globals().popup.id, "BlizzMoveURLDialog")
                    self.assertEqual(lua.globals().popup.data, url)


if __name__ == "__main__":
    unittest.main()
