package com.holdmylua.source.lua_runtime;

import com.holdmylua.source.global.GlobalsStorage;
import com.holdmylua.source.global.LuaContext;
import com.holdmylua.source.patricles.Particle;
import com.holdmylua.source.patricles.ParticleManager;
import com.holdmylua.source.patricles.scripting.Texture;
import com.holdmylua.source.scripting.custom_api.KeyBindManager;
import com.holdmylua.source.scripting.script_wrappers.C;
import com.holdmylua.source.scripting.script_wrappers.Easings;
import com.holdmylua.source.scripting.script_wrappers.I;
import com.holdmylua.source.scripting.script_wrappers.JSItems;
import com.holdmylua.source.scripting.script_wrappers.JSTags;
import com.holdmylua.source.scripting.script_wrappers.M;
import com.holdmylua.source.scripting.script_wrappers.P;
import com.holdmylua.source.scripting.script_wrappers.S;
import com.mojang.blaze3d.vertex.PoseStack;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.components.toasts.SystemToast;
import net.minecraft.client.gui.components.toasts.SystemToast.SystemToastId;
import net.minecraft.client.player.AbstractClientPlayer;
import net.minecraft.network.chat.Component;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.item.BlockItem;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.state.BlockState;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.lib.jse.CoerceJavaToLua;

public class LuaScriptCache {
   public static int swingSpeed = 9;
   private final Globals globals;
   private final LuaValue chunk;
   private boolean canRun = true;
   private static final LuaContext context = new LuaContext();
   private final M mInstance = new M();
   private final I iInstance = new I();
   private final Texture textureInstance = new Texture();
   private final JSItems jsItemsInstance = new JSItems();
   private final JSTags jsTagsInstance = new JSTags();
   private final P pInstance = new P();
   private final Easings easingsInstance = new Easings();
   private final KeyBindManager keyBindManagerInstance = new KeyBindManager();
   private final S sInstance = new S();
   private final C cInstance = new C();
   private final ParticleManager particleManagerInstance = new ParticleManager();

   public LuaScriptCache(String sourceCode) throws IOException {
      this.globals = LuaScriptManager.getInstance().sharedGlobals;
      this.globals.set("M", CoerceJavaToLua.coerce(this.mInstance));
      this.globals.set("I", CoerceJavaToLua.coerce(this.iInstance));
      this.globals.set("Texture", CoerceJavaToLua.coerce(this.textureInstance));
      this.globals.set("Items", CoerceJavaToLua.coerce(this.jsItemsInstance));
      this.globals.set("Tags", CoerceJavaToLua.coerce(this.jsTagsInstance));
      this.globals.set("P", CoerceJavaToLua.coerce(this.pInstance));
      this.globals.set("Easings", CoerceJavaToLua.coerce(this.easingsInstance));
      this.globals.set("KeyBindManager", CoerceJavaToLua.coerce(this.keyBindManagerInstance));
      this.globals.set("S", CoerceJavaToLua.coerce(this.sInstance));
      this.globals.set("C", CoerceJavaToLua.coerce(this.cInstance));
      this.globals.set("particleManager", CoerceJavaToLua.coerce(this.particleManagerInstance));
      this.globals.set("swingSpeed", LuaValue.valueOf(swingSpeed));
      this.globals.set("registry", CoerceJavaToLua.coerce(GlobalsStorage.registry));
      this.globals.set("renderAsBlock", CoerceJavaToLua.coerce(GlobalsStorage.renderAsBlock));
      this.globals.set("translateItem", CoerceJavaToLua.coerce(GlobalsStorage.translateItem));
      this.globals.set("itemSwingSpeed", CoerceJavaToLua.coerce(GlobalsStorage.itemSwingSpeed));
      this.globals.set("animator", CoerceJavaToLua.coerce(GlobalsStorage.modelPartAnimator));
      this.globals.set("renderAsBlock", CoerceJavaToLua.coerce(GlobalsStorage.renderAsBlock));
      this.globals.set("translateItem", CoerceJavaToLua.coerce(GlobalsStorage.translateItem));
      this.globals.set("itemSwingSpeed", CoerceJavaToLua.coerce(GlobalsStorage.itemSwingSpeed));
      this.globals.set("useDuration", CoerceJavaToLua.coerce(GlobalsStorage.useDuration));
      this.globals.set("usingItem", CoerceJavaToLua.coerce(GlobalsStorage.usingItem));
      this.globals.set("debugger", CoerceJavaToLua.coerce(GlobalsStorage.debugTextRenderer));
      this.globals.set("applyBlockRotation", CoerceJavaToLua.coerce(GlobalsStorage.applyBlockRotation));
      this.globals.set("context", CoerceJavaToLua.coerce(context));
      this.chunk = this.globals.load(sourceCode);
   }

   public void execute(
      PoseStack matrices,
      boolean bl,
      HashMap<String, Object> registry,
      float swingProgress,
      ItemStack item,
      AbstractClientPlayer player,
      InteractionHand hand,
      boolean mainHand,
      float deltaTime,
      float equipProgress,
      float mainHandSwingProgress,
      float offHandSwingProgress,
      boolean mainHandSwitchEvent,
      boolean offHandSwitchEvent,
      boolean swingMHand,
      boolean swingOHand,
      boolean interact,
      boolean blockBreaking,
      List<Particle> particles
   ) {
      if (this.canRun) {
         try {
            // PERSONAL-TWEAK: expose the held block's real height (0..1+ block units) to Lua.
            float blockHeight = 1.0F;
            if (item.getItem() instanceof BlockItem) {
               BlockState bs = ((BlockItem)item.getItem()).getBlock().defaultBlockState();
               Level level = Minecraft.getInstance().level;
               if (level != null) {
                  blockHeight = (float)bs.getShape(level, BlockPos.ZERO).max(Direction.Axis.Y);
               }
            }
            context.blockHeight = blockHeight;
            context.update(
               matrices,
               bl,
               swingProgress,
               item,
               player,
               hand,
               mainHand,
               deltaTime,
               equipProgress,
               mainHandSwingProgress,
               offHandSwingProgress,
               mainHandSwitchEvent,
               offHandSwitchEvent,
               swingMHand,
               swingOHand,
               interact,
               blockBreaking,
               particles
            );
            this.chunk.invoke();
         } catch (Exception var21) {
            System.err.println("[HoldMyItems] Lua runtime error: " + var21.getMessage());
            SystemToast.addOrUpdate(
               Minecraft.getInstance().gui.toastManager(),
               SystemToastId.PACK_LOAD_FAILURE,
               Component.nullToEmpty("HMI Lua Runtime error!"),
               Component.nullToEmpty(var21.getMessage())
            );
            this.canRun = false;
         }
      }
   }
}
