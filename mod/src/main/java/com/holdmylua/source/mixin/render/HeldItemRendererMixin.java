package com.holdmylua.source.mixin.render;

import com.holdmylua.source.LuaTestHMI;
import com.holdmylua.source.access.AlternateBlockRenderer;
import com.holdmylua.source.access.ItemStackAccessor;
import com.holdmylua.source.access.LivingEntityAccessor;
import com.holdmylua.source.global.DispatcherStorage;
import com.holdmylua.source.global.GlobalsStorage;
import com.holdmylua.source.global.item_model.ItemModelContext;
import com.holdmylua.source.global.item_model.ItemModelStorage;
import com.holdmylua.source.lua_runtime.LuaScriptCache;
import com.holdmylua.source.lua_runtime.ScriptHolder;
import com.holdmylua.source.patricles.Particle;
import com.holdmylua.source.patricles.ParticleRenderManager;
import com.mojang.blaze3d.vertex.PoseStack;
import com.mojang.math.Axis;
import java.util.ArrayList;
import java.util.List;
import javax.script.ScriptException;
import net.minecraft.client.Minecraft;
import net.minecraft.client.player.AbstractClientPlayer;
import net.minecraft.client.renderer.ItemInHandRenderer;
import net.minecraft.util.LightCoordsUtil;
import net.minecraft.client.renderer.SubmitNodeCollector;
import net.minecraft.client.renderer.blockentity.state.BellRenderState;
import net.minecraft.client.renderer.state.level.CameraRenderState;
import net.minecraft.core.BlockPos;
import net.minecraft.core.component.DataComponents;
import net.minecraft.resources.Identifier;
import net.minecraft.tags.BlockTags;
import net.minecraft.tags.ItemTags;
import net.minecraft.util.Mth;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.entity.HumanoidArm;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.CrossbowItem;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemDisplayContext;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.ItemUseAnimation;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.component.CustomData;
import net.minecraft.world.item.component.CustomModelData;
import net.minecraft.world.item.enchantment.ItemEnchantments;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.LanternBlock;
import net.minecraft.world.level.block.entity.BellBlockEntity;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.state.properties.AttachFace;
import net.minecraft.world.level.block.state.properties.BedPart;
import net.minecraft.world.level.block.state.properties.BellAttachType;
import net.minecraft.world.level.block.state.properties.BlockStateProperties;
import net.minecraft.world.level.block.state.properties.DoubleBlockHalf;
import org.spongepowered.asm.mixin.Final;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.Unique;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Redirect;

@Mixin({ItemInHandRenderer.class})
public abstract class HeldItemRendererMixin {
   @Unique
   boolean mainHandSwitchEvent = false;
   @Unique
   boolean offHandSwitchEvent = false;
   @Unique
   Item prevMainHand = Items.AIR;
   @Unique
   Item prevOffHand = Items.AIR;
   @Unique
   private final ArrayList<Particle> particles = new ArrayList<>();
   @Shadow
   @Final
   private Minecraft minecraft;
   @Shadow
   private ItemStack mainHandItem;
   @Shadow
   private ItemStack offHandItem;
   @Unique
   private boolean swingMHand = false;
   @Unique
   private boolean swingOHand = false;
   @Unique
   private float mainHandSwingProgress = 0.0F;
   @Unique
   private float offHandSwingProgress = 0.0F;

   @Shadow
   protected abstract void renderPlayerArm(PoseStack var1, SubmitNodeCollector var2, int var3, float var4, float var5, HumanoidArm var6);

   @Shadow
   protected abstract void submitArmWithItem(
      AbstractClientPlayer var1,
      float var2,
      float var3,
      InteractionHand var4,
      float var5,
      ItemStack var6,
      float var7,
      PoseStack var8,
      SubmitNodeCollector var9,
      int var10
   );

   @Shadow
   protected abstract void renderMap(PoseStack var1, SubmitNodeCollector var2, int var3, ItemStack var4);

   @Shadow
   public abstract void renderItem(LivingEntity var1, ItemStack var2, ItemDisplayContext var3, PoseStack var4, SubmitNodeCollector var5, int var6);

   @Unique
   private void copyAppearanceComponents(ItemStack source, ItemStack target) {
      if (source.has(DataComponents.ENCHANTMENTS)) {
         target.set(DataComponents.ENCHANTMENTS, (ItemEnchantments)source.get(DataComponents.ENCHANTMENTS));
      }

      if (source.has(DataComponents.ITEM_MODEL)) {
         target.set(DataComponents.ITEM_MODEL, (Identifier)source.get(DataComponents.ITEM_MODEL));
      }

      if (source.has(DataComponents.CUSTOM_MODEL_DATA)) {
         target.set(DataComponents.CUSTOM_MODEL_DATA, (CustomModelData)source.get(DataComponents.CUSTOM_MODEL_DATA));
      }

      if (source.has(DataComponents.CUSTOM_DATA)) {
         target.set(DataComponents.CUSTOM_DATA, (CustomData)source.get(DataComponents.CUSTOM_DATA));
      }
   }

   @Unique
   private void applyArmMatrices(PoseStack matrices, int light, float equipProgress, float swingProgress, HumanoidArm arm) {
      boolean bl = arm != HumanoidArm.LEFT;
      float f = bl ? 1.0F : -1.0F;
      float g = Mth.sqrt(swingProgress);
      float h = -0.3F * Mth.sin(g * (float) Math.PI);
      float i = 0.4F * Mth.sin(g * (float) (Math.PI * 2));
      float j = -0.4F * Mth.sin(swingProgress * (float) Math.PI);
      matrices.translate(f * (h + 0.64000005F), i + -0.6F + equipProgress * -0.6F, j + -0.71999997F);
      matrices.mulPose(Axis.YP.rotationDegrees(f * 45.0F));
      float k = Mth.sin(swingProgress * swingProgress * (float) Math.PI);
      float l = Mth.sin(g * (float) Math.PI);
      matrices.mulPose(Axis.YP.rotationDegrees(f * l * 70.0F));
      matrices.mulPose(Axis.ZP.rotationDegrees(f * k * -20.0F));
      AbstractClientPlayer abstractClientPlayerEntity = this.minecraft.player;
      matrices.translate(f * -1.0F, 3.6F, 3.5F);
      matrices.mulPose(Axis.ZP.rotationDegrees(f * 120.0F));
      matrices.mulPose(Axis.XP.rotationDegrees(200.0F));
      matrices.mulPose(Axis.YP.rotationDegrees(f * -135.0F));
      matrices.translate(f * 5.6F, 0.0F, 0.0F);
   }

   @Unique
   private void itemPose(
      PoseStack matrices,
      ItemStack item,
      boolean bl,
      float swingProgress,
      AbstractClientPlayer player,
      boolean mainHand,
      InteractionHand hand,
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
   ) throws ScriptException, NoSuchMethodException {
      int l = bl ? 1 : -1;
      matrices.translate(0.5 * l, -0.15, -0.85);
      matrices.rotateAround(Axis.XP.rotationDegrees(15.0F), 0.5F, 0.5F, 0.5F);
      matrices.scale(0.9F, 0.9F, 0.9F);
      ScriptHolder.itemScriptCache
         .execute(
            matrices,
            bl,
            GlobalsStorage.registry,
            swingProgress,
            item,
            player,
            hand,
            mainHand,
            LuaTestHMI.deltaTime,
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

      for (LuaScriptCache scriptCache : ScriptHolder.itemAddonsCache) {
         scriptCache.execute(
            matrices,
            bl,
            GlobalsStorage.registry,
            swingProgress,
            item,
            player,
            hand,
            mainHand,
            LuaTestHMI.deltaTime,
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
      }
   }

   @Unique
   private void mainHandPose(
      PoseStack matrices,
      ItemStack item,
      boolean bl,
      float swingProgress,
      float equipProgress,
      AbstractClientPlayer player,
      boolean mainHand,
      InteractionHand hand,
      float mainHandSwingProgress,
      float offHandSwingProgress,
      boolean mainHandSwitchEvent,
      boolean offHandSwitchEvent,
      boolean swingMHand,
      boolean swingOHand,
      boolean interact,
      boolean blockBreaking,
      List<Particle> particles
   ) throws ScriptException, NoSuchMethodException {
      int l = bl ? 1 : -1;
      ScriptHolder.handRelativeScriptCache
         .execute(
            matrices,
            bl,
            GlobalsStorage.registry,
            swingProgress,
            item,
            player,
            hand,
            mainHand,
            LuaTestHMI.deltaTime,
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

      for (LuaScriptCache scriptCache : ScriptHolder.handRelativeAddonsCache) {
         scriptCache.execute(
            matrices,
            bl,
            GlobalsStorage.registry,
            swingProgress,
            item,
            player,
            hand,
            mainHand,
            LuaTestHMI.deltaTime,
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
      }

      if (!item.isEmpty()) {
         matrices.translate(1.5 * l, -0.3, -0.6);
         matrices.rotateAround(Axis.XP.rotationDegrees(15.0F), 0.5F * l, 0.5F, 0.5F);
         matrices.rotateAround(Axis.YP.rotationDegrees(35 * l), 0.5F * l, 0.5F, 0.5F);
         matrices.rotateAround(Axis.ZP.rotationDegrees(-65 * l), 0.5F * l, 0.5F, 0.5F);
         matrices.scale(0.9F, 0.9F, 0.9F);
      }
   }

   @Unique
   private void scenePoseMain(
      PoseStack matrices,
      ItemStack item,
      boolean bl,
      float swingProgress,
      float equipProgress,
      AbstractClientPlayer player,
      boolean mainHand,
      InteractionHand hand,
      float mainHandSwingProgress,
      float offHandSwingProgress,
      boolean mainHandSwitchEvent,
      boolean offHandSwitchEvent,
      boolean swingMHand,
      boolean swingOHand,
      boolean interact,
      boolean blockBreaking,
      List<Particle> particles
   ) throws ScriptException, NoSuchMethodException {
      ScriptHolder.handScriptCache
         .execute(
            matrices,
            bl,
            GlobalsStorage.registry,
            swingProgress,
            item,
            player,
            hand,
            mainHand,
            LuaTestHMI.deltaTime,
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

      for (LuaScriptCache scriptCache : ScriptHolder.handAddonsCache) {
         scriptCache.execute(
            matrices,
            bl,
            GlobalsStorage.registry,
            swingProgress,
            item,
            player,
            hand,
            mainHand,
            LuaTestHMI.deltaTime,
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
      }

      if (!item.isEmpty()) {
         matrices.translate(0.0, -0.35, 0.2);
      }
   }

   @Redirect(
      method = {"submitHandsWithItems(FLcom/mojang/blaze3d/vertex/PoseStack;Lnet/minecraft/client/renderer/SubmitNodeCollector;Lnet/minecraft/client/player/LocalPlayer;I)V"},
      at = @At(
         value = "INVOKE",
         target = "Lnet/minecraft/client/renderer/ItemInHandRenderer;submitArmWithItem(Lnet/minecraft/client/player/AbstractClientPlayer;FFLnet/minecraft/world/InteractionHand;FLnet/minecraft/world/item/ItemStack;FLcom/mojang/blaze3d/vertex/PoseStack;Lnet/minecraft/client/renderer/SubmitNodeCollector;I)V"
      )
   )
   private void renderOverhaul(
      ItemInHandRenderer instance,
      AbstractClientPlayer player,
      float tickProgress,
      float pitch,
      InteractionHand hand,
      float swingProgress,
      ItemStack item,
      float equipProgress,
      PoseStack matrices,
      SubmitNodeCollector orderedRenderCommandQueue,
      int light
   ) throws ScriptException, NoSuchMethodException {
      if (!player.isScoping()) {
         ((ItemStackAccessor)(Object)item).hMI5_0$setTransform(-1);
         boolean bl = hand == InteractionHand.MAIN_HAND;
         boolean interact = false;
         boolean blockBreaking = false;
         if (bl
            && player.isUsingItem()
            && player.getUsedItemHand() != hand
            && (
               player.getOffhandItem().getUseAnimation() == ItemUseAnimation.BOW
                  || player.getOffhandItem().getUseAnimation() == ItemUseAnimation.BOW
                  || player.getOffhandItem().getUseAnimation() == ItemUseAnimation.CROSSBOW && !CrossbowItem.isCharged(player.getOffhandItem())
            )) {
            item = Items.AIR.getDefaultInstance();
         }

         if (!bl
            && player.isUsingItem()
            && player.getUsedItemHand() != hand
            && (
               player.getMainHandItem().getUseAnimation() == ItemUseAnimation.BOW
                  || player.getMainHandItem().getUseAnimation() == ItemUseAnimation.CROSSBOW && !CrossbowItem.isCharged(player.getMainHandItem())
            )) {
            item = Items.AIR.getDefaultInstance();
         }

         if (bl) {
            this.mainHandSwitchEvent = item.getItem() != this.prevMainHand;
         }

         if (!bl) {
            this.offHandSwitchEvent = item.getItem() != this.prevOffHand;
         }

         matrices.pushPose();
         if (player instanceof LivingEntityAccessor accessor) {
            float mainHandProgress = accessor.hMI5_0$getMainHandSwingProgress(tickProgress);
            this.mainHandSwingProgress = mainHandProgress;
            float offHandProgress = accessor.hMI5_0$getOffHandSwingProgress(tickProgress);
            this.offHandSwingProgress = offHandProgress;
            swingProgress = bl ? mainHandProgress : offHandProgress;
            this.swingMHand = accessor.hMI5_0$getMHandEvent();
            this.swingOHand = accessor.hMI5_0$getOHandEvent();
            if (bl) {
               interact = accessor.hMI5_0$getMInteract();
            } else {
               interact = accessor.hMI5_0$getOInteract();
            }

            blockBreaking = accessor.hMI5_0$getBlockBreak();
         }

         HumanoidArm arm = bl ? player.getMainArm() : player.getMainArm().getOpposite();
         boolean bl2 = arm == HumanoidArm.RIGHT;
         int l = bl2 ? 1 : -1;
         this.scenePoseMain(
            matrices,
            item,
            bl2,
            swingProgress,
            equipProgress,
            player,
            bl,
            hand,
            this.mainHandSwingProgress,
            this.offHandSwingProgress,
            this.mainHandSwitchEvent,
            this.offHandSwitchEvent,
            this.swingMHand,
            this.swingOHand,
            interact,
            blockBreaking,
            this.particles
         );
         matrices.pushPose();
         this.mainHandPose(
            matrices,
            item,
            bl2,
            swingProgress,
            equipProgress,
            player,
            bl,
            hand,
            this.mainHandSwingProgress,
            this.offHandSwingProgress,
            this.mainHandSwitchEvent,
            this.offHandSwitchEvent,
            this.swingMHand,
            this.swingOHand,
            interact,
            blockBreaking,
            this.particles
         );
         int combinedLight = LightCoordsUtil.lightCoordsWithEmission(light, Block.byItem(item.getItem()).defaultBlockState().getLightEmission());
         if (player.isInvisible()) {
            this.applyArmMatrices(matrices, combinedLight, 0.0F, 0.0F, arm);
         } else {
            this.renderPlayerArm(matrices, orderedRenderCommandQueue, combinedLight, 0.0F, 0.0F, arm);
         }

         matrices.popPose();
         matrices.pushPose();
         if (Block.byItem(item.getItem()) != Blocks.AIR
            && !Block.byItem(item.getItem()).defaultBlockState().is(BlockTags.INSIDE_STEP_SOUND_BLOCKS)
            && !Block.byItem(item.getItem()).defaultBlockState().is(BlockTags.CROPS)
            && item.getUseAnimation() != ItemUseAnimation.EAT
            && !item.is(Items.REDSTONE)
            && !item.is(ItemTags.BANNERS)
            && !item.is(ItemTags.SKULLS)
            && GlobalsStorage.renderAsBlock.getOrDefault(item.getItem().toString(), true)) {
            swingProgress = 0.0F;
            BlockState blockState = Block.byItem(item.getItem()).defaultBlockState();
            this.itemPose(
               matrices,
               item,
               bl2,
               swingProgress,
               player,
               bl,
               hand,
               equipProgress,
               this.mainHandSwingProgress,
               this.offHandSwingProgress,
               this.mainHandSwitchEvent,
               this.offHandSwitchEvent,
               this.swingMHand,
               this.swingOHand,
               interact,
               blockBreaking,
               this.particles
            );
            matrices.translate(0.22 * l, 0.25, 0.2);
            if (item.is(Items.LEVER) || blockState.is(BlockTags.BUTTONS)) {
               blockState = (BlockState)blockState.setValue(BlockStateProperties.ATTACH_FACE, AttachFace.FLOOR);
            }

            // PORT-26.2: held hanging signs used the CEILING_MIDDLE model (with the top
            // chain bar) via the removed special renderer; the block pipeline would render
            // the plain ceiling state, leaving the chains looking detached. The "attached"
            // variant keeps the vertical chain bar, so render that instead.
            if (blockState.hasProperty(BlockStateProperties.ATTACHED)) {
               blockState = (BlockState)blockState.setValue(BlockStateProperties.ATTACHED, true);
            }

            if (!item.getHoverName().toString().toLowerCase().contains("torch")
               && !(Block.byItem(item.getItem()) instanceof LanternBlock)
               && !blockState.is(BlockTags.ALL_HANGING_SIGNS)) {
               matrices.translate(-0.25 * l, -0.05, 0.0);
            } else {
               matrices.translate(-0.05 * l, 0.0, 0.0);
               matrices.scale(1.75F, 1.75F, 1.75F);
            }

            matrices.pushPose();
            matrices.scale(0.3F, 0.3F, 0.3F);
            matrices.translate(-0.9 * l, -0.45, -0.7);
            matrices.popPose();
            if (!bl2) {
               matrices.translate(-0.3F, 0.0F, 0.0F);
            }

            matrices.scale(0.3F, 0.3F, 0.3F);
            matrices.translate(-0.9 * l, -0.45, -0.7);
            if (item.is(Items.BELL)) {
               BellBlockEntity bellBlockEntity = new BellBlockEntity(BlockPos.ZERO, Blocks.BELL.defaultBlockState());
               BellRenderState state = new BellRenderState();
               state.lightCoords = light;
               this.minecraft
                  .getBlockEntityRenderDispatcher()
                  .getRenderer(bellBlockEntity)
                  .submit(state, matrices, orderedRenderCommandQueue, new CameraRenderState());
               ((AlternateBlockRenderer)(Object)this.minecraft.getModelManager().getBlockStateModelSet())
                  .renderSingleBlockWithEmission(
                     (BlockState)Blocks.BELL.defaultBlockState().setValue(BlockStateProperties.BELL_ATTACHMENT, BellAttachType.CEILING),
                     matrices,
                     orderedRenderCommandQueue,
                     light,
                     this.minecraft.level,
                     player
                  );
            } else {
               if (blockState.hasProperty(BlockStateProperties.BED_PART)) {
                  // PORT-26.2: beds use PART (HEAD/FOOT), not DOUBLE_BLOCK_HALF, so the
                  // old code only ever rendered the default (FOOT) half. Render both
                  // halves with the head at the origin and the foot +1 z, matching the
                  // 26.2 item model (headboard points forward along the hand).
                  ((AlternateBlockRenderer)(Object)this.minecraft.getModelManager().getBlockStateModelSet())
                     .renderSingleBlockWithEmission(
                        (BlockState)blockState.setValue(BlockStateProperties.BED_PART, BedPart.HEAD),
                        matrices,
                        orderedRenderCommandQueue,
                        light,
                        this.minecraft.level,
                        player
                     );
                  matrices.pushPose();
                  matrices.translate(0.0F, 0.0F, 1.0F);
                  ((AlternateBlockRenderer)(Object)this.minecraft.getModelManager().getBlockStateModelSet())
                     .renderSingleBlockWithEmission(
                        (BlockState)blockState.setValue(BlockStateProperties.BED_PART, BedPart.FOOT),
                        matrices,
                        orderedRenderCommandQueue,
                        light,
                        this.minecraft.level,
                        player
                     );
                  matrices.popPose();
               } else {
                  if (blockState.hasProperty(BlockStateProperties.DOUBLE_BLOCK_HALF)) {
                     matrices.pushPose();
                     matrices.translate(0.0F, 1.0F, 0.0F);
                     ((AlternateBlockRenderer)(Object)this.minecraft.getModelManager().getBlockStateModelSet())
                        .renderSingleBlockWithEmission(
                           (BlockState)blockState.setValue(BlockStateProperties.DOUBLE_BLOCK_HALF, DoubleBlockHalf.UPPER),
                           matrices,
                           orderedRenderCommandQueue,
                           light,
                           this.minecraft.level,
                           player
                        );
                     matrices.popPose();
                  }

                  ((AlternateBlockRenderer)(Object)this.minecraft.getModelManager().getBlockStateModelSet())
                     .renderSingleBlockWithEmission(blockState, matrices, orderedRenderCommandQueue, light, this.minecraft.level, player);
               }
            }

            matrices.pushPose();
            if (!bl2) {
               matrices.translate(1.0F, 0.0F, 0.0F);
            }

            ParticleRenderManager.draw(this.particles, matrices, orderedRenderCommandQueue, "ITEM", hand, light, player, tickProgress);
            matrices.popPose();
         } else if (item.getUseAnimation() != ItemUseAnimation.BLOCK
            && item.getUseAnimation() != ItemUseAnimation.BRUSH
            && item.getUseAnimation() != ItemUseAnimation.TRIDENT) {
            this.itemPose(
               matrices,
               item,
               bl2,
               swingProgress,
               player,
               bl,
               hand,
               equipProgress,
               this.mainHandSwingProgress,
               this.offHandSwingProgress,
               this.mainHandSwitchEvent,
               this.offHandSwitchEvent,
               this.swingMHand,
               this.swingOHand,
               interact,
               blockBreaking,
               this.particles
            );
            if (item.has(DataComponents.MAP_ID)) {
               matrices.pushPose();
               matrices.translate(-0.05 * l, 0.2, 0.1);
               matrices.mulPose(Axis.YP.rotationDegrees(-12 * l));
               this.renderMap(matrices, orderedRenderCommandQueue, light, item);
               matrices.popPose();
            } else {
               ItemStack renderStack = bl ? GlobalsStorage.mainHandItem : GlobalsStorage.offHandItem;
               if (renderStack.is(Items.AIR)) {
                  renderStack = item;
               }

               DispatcherStorage.setItem(item);
               ItemModelStorage.addData(
                  new ItemModelContext(
                     bl2,
                     swingProgress,
                     player,
                     hand,
                     bl,
                     LuaTestHMI.deltaTime,
                     equipProgress,
                     this.mainHandSwingProgress,
                     this.offHandSwingProgress,
                     this.mainHandSwitchEvent,
                     this.offHandSwitchEvent,
                     this.swingMHand,
                     this.swingOHand,
                     interact,
                     blockBreaking,
                     item
                  ),
                  item
               );
               this.renderItem(
                  player,
                  renderStack,
                  bl2 ? ItemDisplayContext.THIRD_PERSON_RIGHT_HAND : ItemDisplayContext.THIRD_PERSON_LEFT_HAND,
                  matrices,
                  orderedRenderCommandQueue,
                  light
               );
            }

            if (bl2) {
               LuaTestHMI.matricesMain.set(matrices.last().pose());
            } else {
               LuaTestHMI.matricesOff.set(matrices.last().pose());
            }

            matrices.pushPose();
            ParticleRenderManager.draw(this.particles, matrices, orderedRenderCommandQueue, "ITEM", hand, light, player, tickProgress);
            matrices.popPose();
         } else {
            this.itemPose(
               matrices,
               item,
               bl2,
               swingProgress,
               player,
               bl,
               hand,
               equipProgress,
               this.mainHandSwingProgress,
               this.offHandSwingProgress,
               this.mainHandSwitchEvent,
               this.offHandSwitchEvent,
               this.swingMHand,
               this.swingOHand,
               interact,
               blockBreaking,
               this.particles
            );
            ItemStack renderStack = new ItemStack(item.getItem(), item.getCount());
            this.copyAppearanceComponents(item, renderStack);
            ItemStack renderStack2 = bl ? GlobalsStorage.mainHandItem : GlobalsStorage.offHandItem;
            if (!renderStack2.is(Items.AIR)) {
               renderStack = renderStack2;
            }

            DispatcherStorage.setItem(item);
            ItemModelStorage.addData(
               new ItemModelContext(
                  bl2,
                  swingProgress,
                  player,
                  hand,
                  bl,
                  LuaTestHMI.deltaTime,
                  equipProgress,
                  this.mainHandSwingProgress,
                  this.offHandSwingProgress,
                  this.mainHandSwitchEvent,
                  this.offHandSwitchEvent,
                  this.swingMHand,
                  this.swingOHand,
                  interact,
                  blockBreaking,
                  item
               ),
               item
            );
            this.renderItem(
               player,
               renderStack,
               bl2 ? ItemDisplayContext.THIRD_PERSON_RIGHT_HAND : ItemDisplayContext.THIRD_PERSON_LEFT_HAND,
               matrices,
               orderedRenderCommandQueue,
               light
            );
         }

         matrices.popPose();
         matrices.popPose();
         if (bl) {
            this.prevMainHand = item.getItem();
         }

         if (!bl) {
            this.prevOffHand = item.getItem();
         }

         matrices.pushPose();
         ParticleRenderManager.draw(this.particles, matrices, orderedRenderCommandQueue, "SCREEN", hand, light, player, tickProgress);
         matrices.popPose();
         LuaTestHMI.tickProgress = tickProgress;
         GlobalsStorage.offHandItem = Items.AIR.getDefaultInstance();
         GlobalsStorage.mainHandItem = Items.AIR.getDefaultInstance();
      }
   }
}
