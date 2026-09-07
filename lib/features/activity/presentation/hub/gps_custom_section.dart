import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

/// Custom tools for GPS activities (Route suggestions & Saved routes).
class GpsCustomSection extends StatelessWidget {
  const GpsCustomSection({required this.type, super.key});

  final ActivityType type;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  unawaited(
                    RouteSuggestRouteData(
                      type: type.toStorage(),
                    ).push<void>(context),
                  );
                },
                icon: const Icon(Icons.route_outlined),
                label: Text('Suggest ${type.label} Route'),
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  unawaited(
                    const ActivityRoutesRouteData().push<void>(context),
                  );
                },
                icon: const Icon(Icons.bookmark_border_outlined),
                label: const Text('Saved Routes'),
              ),
            ),
          ],
        ),
        // Walking only: everyday steps are the thing a walker's hub is
        // missing, and they are not a meaningful companion to a ride or a
        // hike's route tools.
        if (type == ActivityType.walk) ...[
          SizedBox(height: tokens.spacingSm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('walkingHubDailyStepsButton'),
              onPressed: () {
                unawaited(const StepsRouteData().push<void>(context));
              },
              icon: const Icon(Icons.directions_walk_outlined),
              label: const Text('Daily steps'),
            ),
          ),
        ],
      ],
    );
  }
}
