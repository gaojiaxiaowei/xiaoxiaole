/// 方块形状定义
/// 每个形状用相对坐标数组表示

import 'package:flutter/material.dart';
import 'dart:math';
import 'themes/themes.dart';

class Block {
  final String id;
  final List<Offset> shape;  // 相对坐标
  final String name;  // 颜色从主题获取

  const Block({
    required this.id,
    required this.shape,
    required this.name,
  });

  /// 获取方块颜色（从当前主题）
  Color get color => ThemeManager.instance.currentTheme.getBlockColor(id);

  /// 预定义方块形状（不再包含颜色，颜色由主题提供）
  static const List<Block> allBlocks = [
    // 单格
    Block(
      id: 'single',
      shape: [Offset(0, 0)],
      name: '单格',
    ),
    // 横条 2格
    Block(
      id: 'h2',
      shape: [Offset(0, 0), Offset(1, 0)],
      name: '横2',
    ),
    // 横条 3格
    Block(
      id: 'h3',
      shape: [Offset(0, 0), Offset(1, 0), Offset(2, 0)],
      name: '横3',
    ),
    // 横条 4格
    Block(
      id: 'h4',
      shape: [Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(3, 0)],
      name: '横4',
    ),
    // 竖条 2格
    Block(
      id: 'v2',
      shape: [Offset(0, 0), Offset(0, 1)],
      name: '竖2',
    ),
    // 竖条 3格
    Block(
      id: 'v3',
      shape: [Offset(0, 0), Offset(0, 1), Offset(0, 2)],
      name: '竖3',
    ),
    // 竖条 4格
    Block(
      id: 'v4',
      shape: [Offset(0, 0), Offset(0, 1), Offset(0, 2), Offset(0, 3)],
      name: '竖4',
    ),
    // 方块 2x2
    Block(
      id: 'square',
      shape: [Offset(0, 0), Offset(1, 0), Offset(0, 1), Offset(1, 1)],
      name: '方块',
    ),
    // L形
    Block(
      id: 'l',
      shape: [Offset(0, 0), Offset(0, 1), Offset(0, 2), Offset(1, 2)],
      name: 'L形',
    ),
    // 反L形
    Block(
      id: 'rl',
      shape: [Offset(1, 0), Offset(1, 1), Offset(1, 2), Offset(0, 2)],
      name: '反L',
    ),
    // T形
    Block(
      id: 't',
      shape: [Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(1, 1)],
      name: 'T形',
    ),
    // Z形
    Block(
      id: 'z',
      shape: [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(2, 1)],
      name: 'Z形',
    ),
    // S形
    Block(
      id: 's',
      shape: [Offset(1, 0), Offset(2, 0), Offset(0, 1), Offset(1, 1)],
      name: 'S形',
    ),
    // 十字形
    Block(
      id: 'cross',
      shape: [Offset(1, 0), Offset(0, 1), Offset(1, 1), Offset(2, 1), Offset(1, 2)],
      name: '十字',
    ),
    // 横条 5格
    Block(
      id: 'h5',
      shape: [Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(3, 0), Offset(4, 0)],
      name: '横5',
    ),
    // 竖条 5格
    Block(
      id: 'v5',
      shape: [Offset(0, 0), Offset(0, 1), Offset(0, 2), Offset(0, 3), Offset(0, 4)],
      name: '竖5',
    ),
    // 3x3大方块
    Block(
      id: 'bigSquare',
      shape: [
        Offset(0, 0), Offset(1, 0), Offset(2, 0),
        Offset(0, 1), Offset(1, 1), Offset(2, 1),
        Offset(0, 2), Offset(1, 2), Offset(2, 2),
      ],
      name: '大方块',
    ),
    // 阶梯形
    Block(
      id: 'stairs',
      shape: [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(2, 1), Offset(2, 2), Offset(3, 2)],
      name: '阶梯',
    ),
    // U形
    Block(
      id: 'u',
      shape: [Offset(0, 0), Offset(2, 0), Offset(0, 1), Offset(1, 1), Offset(2, 1)],
      name: 'U形',
    ),
    // 大T形
    Block(
      id: 'bigT',
      shape: [
        Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(3, 0),
        Offset(1, 1), Offset(2, 1),
        Offset(2, 2),
      ],
      name: '大T',
    ),
  ];

  /// 随机获取3个方块
  static List<Block> getRandomBlocks() {
    final random = Random();
    final blocks = List<Block>.from(allBlocks)..shuffle(random);
    return blocks.take(3).toList();
  }

  /// 简单难度方块池（只有小方块，更容易放置）
  static const List<String> _easyBlockIds = [
    'single', 'h2', 'v2', 'h3', 'v3', 'square', 'h4', 'v4',
  ];

  /// 困难难度方块池（偏向大块和复杂形状）
  static const List<String> _hardBlockIds = [
    'h4', 'v4', 'h5', 'v5', 'square', 'bigSquare',
    'cross', 'bigT', 'stairs', 'l', 'rl', 't', 'u',
  ];

  /// 根据难度获取方块
  /// easy: 固定使用简单方块池
  /// normal: 使用现有逻辑（根据分数动态调整）
  /// hard: 固定使用困难方块池
  static List<Block> getBlocksByUserDifficulty(String difficulty, int score) {
    final random = Random();

    switch (difficulty) {
      case 'easy':
        // 简单难度：从简单方块池随机选3个
        final easyBlocks = allBlocks.where((b) => _easyBlockIds.contains(b.id)).toList();
        easyBlocks.shuffle(random);
        return easyBlocks.take(3).toList();

      case 'hard':
        // 困难难度：从困难方块池随机选2-3个
        final hardBlocks = allBlocks.where((b) => _hardBlockIds.contains(b.id)).toList();
        hardBlocks.shuffle(random);
        final count = random.nextBool() ? 3 : 2;
        return hardBlocks.take(count).toList();

      case 'normal':
      default:
        // 普通难度：使用原有的分数难度逻辑
        return getBlocksByDifficulty(score);
    }
  }

  /// 根据分数难度获取方块
  /// 难度递增机制：
  /// - 0-500分：3个方块
  /// - 501-1000分：2-3个方块随机
  /// - 1001分以上：2个方块
  /// - 高分时大方块概率降低30%
  /// - 高分时更刁钻的方块组合
  static List<Block> getBlocksByDifficulty(int score) {
    final random = Random();

    // 根据分数决定方块数量
    int blockCount;
    if (score <= 500) {
      blockCount = 3;
    } else if (score <= 1000) {
      blockCount = random.nextBool() ? 3 : 2;
    } else {
      blockCount = 2;
    }

    // 复制可用方块列表
    var availableBlocks = List<Block>.from(allBlocks);

    // 高分时降低大方块概率（形状格数 >= 7 的方块）
    if (score > 1000) {
      // 70% 概率移除大方块
      if (random.nextDouble() < 0.7) {
        availableBlocks.removeWhere((b) => b.shape.length >= 7);
      }
    } else if (score > 500) {
      // 中等分数，30% 概率降低大方块
      if (random.nextDouble() < 0.3) {
        availableBlocks.removeWhere((b) => b.shape.length >= 7);
      }
    }

    // 高分时增加刁钻方块的概率（小方块优先）
    if (score > 1500) {
      // 按形状大小排序，小的在前
      availableBlocks.sort((a, b) => a.shape.length.compareTo(b.shape.length));
      // 前50%的小方块概率更高
      final smallBlocks = availableBlocks.take((availableBlocks.length * 0.5).floor()).toList();
      final largeBlocks = availableBlocks.skip((availableBlocks.length * 0.5).floor()).toList();

      // 洗牌后再混合，保证小方块有更高概率被选中
      smallBlocks.shuffle(random);
      largeBlocks.shuffle(random);

      // 小方块放前面
      availableBlocks = [...smallBlocks, ...largeBlocks];
    } else {
      availableBlocks.shuffle(random);
    }

    return availableBlocks.take(blockCount).toList();
  }
}
