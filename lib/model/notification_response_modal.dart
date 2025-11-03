class NotificationResponse {
  final int? allCount;
  final List<NotificationItem>? allList;

  NotificationResponse({
    this.allCount,
    this.allList,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      allCount: json['all_count'] as int?,
      allList: (json['all_list'] as List<dynamic>?)
          ?.map((item) => NotificationItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'all_count': allCount,
    'all_list': allList?.map((item) => item.toJson()).toList(),
  };
}

class NotificationItem {
  final int? id;
  final String? level;
  final int? recipient;
  final bool? unread;
  final int? actorContentType;
  final String? actorObjectId;
  final String? verb;
  final String? description;
  final String? targetContentType;
  final String? targetObjectId;
  final String? actionObjectContentType;
  final String? actionObjectObjectId;
  final DateTime? timestamp;
  final bool? isPublic;
  final bool? deleted;
  final bool? emailed;
  final dynamic data; // Since data is null, using dynamic type
  final int? slug;
  final String? actor;

  NotificationItem({
    this.id,
    this.level,
    this.recipient,
    this.unread,
    this.actorContentType,
    this.actorObjectId,
    this.verb,
    this.description,
    this.targetContentType,
    this.targetObjectId,
    this.actionObjectContentType,
    this.actionObjectObjectId,
    this.timestamp,
    this.isPublic,
    this.deleted,
    this.emailed,
    this.data,
    this.slug,
    this.actor,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int?,
      level: json['level'] as String?,
      recipient: json['recipient'] as int?,
      unread: json['unread'] as bool?,
      actorContentType: json['actor_content_type'] as int?,
      actorObjectId: json['actor_object_id'] as String?,
      verb: json['verb'] as String?,
      description: json['description'] as String?,
      targetContentType: json['target_content_type'] as String?,
      targetObjectId: json['target_object_id'] as String?,
      actionObjectContentType: json['action_object_content_type'] as String?,
      actionObjectObjectId: json['action_object_object_id'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      isPublic: json['public'] as bool?,
      deleted: json['deleted'] as bool?,
      emailed: json['emailed'] as bool?,
      data: json['data'], // Using dynamic type for flexibility
      slug: json['slug'] as int?,
      actor: json['actor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
    'recipient': recipient,
    'unread': unread,
    'actor_content_type': actorContentType,
    'actor_object_id': actorObjectId,
    'verb': verb,
    'description': description,
    'target_content_type': targetContentType,
    'target_object_id': targetObjectId,
    'action_object_content_type': actionObjectContentType,
    'action_object_object_id': actionObjectObjectId,
    'timestamp': timestamp?.toIso8601String(),
    'public': isPublic,
    'deleted': deleted,
    'emailed': emailed,
    'data': data,
    'slug': slug,
    'actor': actor,
  };
}
