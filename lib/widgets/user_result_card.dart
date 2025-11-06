import 'package:flutter/material.dart';
import '../models/search_result.dart';
class UserResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback? onTap;

  const UserResultCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = result.user;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(user.avatarUrl),
                onBackgroundImageError: (_, __) {},
                child: user.avatarUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _MatchTypeBadge(matchType: result.matchType),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${user.occupation} • ${user.skills.join(', ')}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.rating} (${user.reviewCount} reviews)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchTypeBadge extends StatelessWidget {
  final MatchType matchType;

  const _MatchTypeBadge({required this.matchType});

  String _getLabel() {
    switch (matchType) {
      case MatchType.username:
        return 'Username';
      case MatchType.name:
        return 'Name';
      case MatchType.occupation:
        return 'Occupation';
      case MatchType.category:
        return 'Skill';
    }
  }

  Color _getColor() {
    switch (matchType) {
      case MatchType.username:
        return Colors.green;
      case MatchType.name:
        return Colors.blue;
      case MatchType.occupation:
        return Colors.orange;
      case MatchType.category:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getColor().withOpacity(0.3), width: 1),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getColor(),
        ),
      ),
    );
  }
}


