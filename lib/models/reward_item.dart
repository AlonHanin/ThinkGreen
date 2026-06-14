import '../services/api/api_payload_utils.dart';

class RewardItem {
  final String id;
  final String title;
  final int cost;
  final String emoji;
  final String partnerName;
  final String description;
  final bool isActive;
  final int sortOrder;

  const RewardItem({
    required this.id,
    required this.title,
    required this.cost,
    required this.emoji,
    required this.partnerName,
    required this.description,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory RewardItem.fromApi(Map<String, dynamic> map) {
    final partnerMap =
        firstNestedMap(map, const ['partner_business', 'partner']) ?? const {};
    return RewardItem(
      id: firstString(map, const ['public_id', 'id', 'reward_id']) ?? '',
      title: firstString(map, const ['title', 'name']) ?? 'Reward',
      cost: firstInt(map, const ['points_cost', 'cost', 'points']) ?? 0,
      emoji: firstString(map, const ['icon', 'emoji']) ?? '🎁',
      partnerName:
          firstString(map, const ['partner_business_name', 'partner_name']) ??
          firstString(partnerMap, const ['name', 'title']) ??
          '',
      description: firstString(map, const ['description', 'details']) ?? '',
      isActive:
          map['is_active'] == null
              ? true
              : map['is_active'] == true || map['is_active'] == 1,
      sortOrder: firstInt(map, const ['sort_order', 'order']) ?? 0,
    );
  }
}

class RewardRedemption {
  final String id;
  final RewardItem reward;
  final DateTime redeemedAt;
  final String redemptionCode;

  const RewardRedemption({
    required this.id,
    required this.reward,
    required this.redeemedAt,
    required this.redemptionCode,
  });

  factory RewardRedemption.fromApi(
    Map<String, dynamic> map, {
    RewardItem? reward,
  }) {
    final rewardMap = firstNestedMap(map, const ['reward']) ?? map;
    return RewardRedemption(
      id: firstString(map, const ['public_id', 'id', 'redemption_id']) ?? '',
      reward: reward ?? RewardItem.fromApi(rewardMap),
      redeemedAt:
          firstDateTime(map, const [
            'redeemed_at',
            'created_at',
            'redeemedAt',
          ]) ??
          DateTime.now(),
      redemptionCode: firstString(map, const ['redemption_code', 'code']) ?? '',
    );
  }
}

class PartnerBusiness {
  final String name;
  final String rewards;
  final String location;

  const PartnerBusiness({
    required this.name,
    required this.rewards,
    required this.location,
  });

  factory PartnerBusiness.fromApi(Map<String, dynamic> map) {
    return PartnerBusiness(
      name: firstString(map, const ['name', 'title']) ?? '',
      rewards:
          firstString(map, const ['rewards', 'summary', 'description']) ?? '',
      location: firstString(map, const ['location', 'address', 'city']) ?? '',
    );
  }
}
