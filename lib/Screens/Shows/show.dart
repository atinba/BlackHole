/*
 *  This file is part of BlackHole (https://github.com/BrightDV/BlackHole).
 * 
 * BlackHole is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BlackHole is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BlackHole.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2023, Ankit Sangwan
 */

import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:blackhole/Helpers/format.dart';
import 'package:blackhole/Models/url_image_generator.dart';
import 'package:blackhole/Screens/Common/song_list.dart';
import 'package:blackhole/Services/player_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SeasonsList extends StatelessWidget {
  final List seasons;
  final String showId;
  const SeasonsList(this.seasons, this.showId, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: seasons.length,
      itemBuilder: (context, index) => GestureDetector(
        child: Card(
          elevation: 5.0,
          child: SizedBox(
            height: 90,
            child: Row(
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      errorWidget: (context, _, __) => const Image(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/album.png'),
                      ),
                      imageUrl:
                          UrlImageGetter([seasons[index]['image']?.toString()])
                              .mediumQuality,
                      placeholder: (context, url) => const Image(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/album.png'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        seasons[index]['title'].toString(),
                      ),
                      Text(
                        '${seasons[index]['more_info']['numEpisodes']} episodes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (
              _,
              __,
              ___,
            ) =>
                SongsListPage(
              listItem: {
                'id': showId,
                'title': seasons[index]['title'].toString(),
                'numEpisodes':
                    seasons[index]['more_info']['numEpisodes'].toString(),
                'type': 'season',
                'season_number': index + 1,
                'image': seasons[index]['image'],
              },
            ),
          ),
        ),
      ),
      shrinkWrap: true,
    );
  }
}

class EpisodesList extends StatelessWidget {
  final List episodes;
  const EpisodesList(this.episodes, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: episodes.map((entry) {
        return GestureDetector(
          child: Card(
            elevation: 5.0,
            child: Column(
              children: [
                SizedBox(
                  height: 90,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            errorWidget: (context, _, __) => const Image(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/album.png'),
                            ),
                            imageUrl:
                                UrlImageGetter([entry['image']?.toString()])
                                    .mediumQuality,
                            placeholder: (context, url) => const Image(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/album.png'),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 138,
                          child: Text(
                            entry['title'].toString(),
                            textAlign: TextAlign.justify,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      /* const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DownloadButton(
                        data: entry as Map,
                        icon: 'download',
                      ),
                      LikeButton(
                        mediaItem: null,
                        data: entry,
                      ),
                      SongTileTrailingMenu(data: entry),
                    ],
                  ), */
                    ],
                  ),
                ),
                if (entry['more_info'] != null)
                  if (entry['more_info']['description'] != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 5, right: 5, bottom: 7),
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                entry['more_info']['description']
                                    .toString()
                                    .replaceAll('&amp;', '&')
                                    .replaceAll('&#039;', "'")
                                    .replaceAll('&quot;', '"'),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          entry['more_info']['description']
                              .toString()
                              .replaceAll('&amp;', '&')
                              .replaceAll('&#039;', "'")
                              .replaceAll('&quot;', '"'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
              ],
            ),
          ),
          onTap: () async {
            final List formatedEpisodes =
                await FormatResponse.formatEpisodesInList(episodes);
            PlayerInvoke.init(
              songsList: formatedEpisodes,
              index: formatedEpisodes.indexWhere(
                (element) => element['id'] == entry['id'],
              ),
              isOffline: false,
              recommend: false,
            );
          },
          onLongPress: () {
            copyToClipboard(
              context: context,
              text: '${entry["title"]}',
            );
          },
        );
      }).toList(),
    );
  }
}
