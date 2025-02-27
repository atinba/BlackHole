import 'package:blackhole/CustomWidgets/box_switch_tile.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class MusicPlaybackPage extends StatefulWidget {
  final Function? callback;
  const MusicPlaybackPage({this.callback});

  @override
  State<MusicPlaybackPage> createState() => _MusicPlaybackPageState();
}

class _MusicPlaybackPageState extends State<MusicPlaybackPage> {
  String streamingMobileQuality = Hive.box('settings')
      .get('streamingQuality', defaultValue: '320 kbps') as String;
  String ytQuality =
      Hive.box('settings').get('ytQuality', defaultValue: 'High') as String;

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(
              context,
            )!
                .musicPlayback,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .streamQuality,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .streamQualitySub,
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: streamingMobileQuality,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(
                      () {
                        streamingMobileQuality = newValue;
                        Hive.box('settings').put('streamingQuality', newValue);
                      },
                    );
                  }
                },
                items: <String>['96 kbps', '160 kbps', '320 kbps']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              dense: true,
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .ytStreamQuality,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .ytStreamQualitySub,
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: ytQuality,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(
                      () {
                        ytQuality = newValue;
                        Hive.box('settings').put('ytQuality', newValue);
                      },
                    );
                  }
                },
                items: <String>['Low', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              dense: true,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .loadLast,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .loadLastSub,
              ),
              keyName: 'loadStart',
              defaultValue: true,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .resetOnSkip,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .resetOnSkipSub,
              ),
              keyName: 'resetOnSkip',
              defaultValue: false,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .enforceRepeat,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .enforceRepeatSub,
              ),
              keyName: 'enforceRepeat',
              defaultValue: false,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .autoplay,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .autoplaySub,
              ),
              keyName: 'autoplay',
              defaultValue: true,
              isThreeLine: true,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .cacheSong,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .cacheSongSub,
              ),
              keyName: 'cacheSong',
              defaultValue: false,
            ),
          ],
        ),
      ),
    );
  }
}