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

import 'dart:async';

import 'package:blackhole/APIs/api.dart';
import 'package:blackhole/CustomWidgets/bouncy_playlist_header_scroll_view.dart';
import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:blackhole/CustomWidgets/download_button.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/image_card.dart';
import 'package:blackhole/CustomWidgets/like_button.dart';
import 'package:blackhole/CustomWidgets/on_hover.dart';
import 'package:blackhole/CustomWidgets/playlist_popupmenu.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:blackhole/Helpers/extensions.dart';
import 'package:blackhole/Helpers/image_resolution_modifier.dart';
import 'package:blackhole/Models/image_quality.dart';
import 'package:blackhole/Models/url_image_generator.dart';
import 'package:blackhole/Screens/Shows/show.dart';
import 'package:blackhole/Services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

class SongsListPage extends StatefulWidget {
  final Map listItem;

  const SongsListPage({
    super.key,
    required this.listItem,
  });

  @override
  _SongsListPageState createState() => _SongsListPageState();
}

class _SongsListPageState extends State<SongsListPage> {
  int page = 0; // TODO: fix
  bool loading = false;
  List songList = [];
  bool fetched = false;
  bool isSharePopupShown = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSongs();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          (widget.listItem['type'].toString() == 'songs' ||
              widget.listItem['type'].toString() == 'top-songs' ||
              widget.listItem['type'].toString() == 'season' ||
              widget.listItem['type'].toString() == 'show') &&
          !loading) {
        page += 1;
        _fetchSongs();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _fetchSongs() {
    loading = true;
    try {
      switch (widget.listItem['type'].toString()) {
        case 'songs':
          SaavnAPI()
              .fetchSongSearchResults(
            searchQuery: widget.listItem['id'].toString(),
            page: page,
          )
              .then((value) {
            setState(() {
              songList.addAll(value['songs'] as List);
              fetched = true;
              loading = false;
            });
            if (value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
        case 'top-songs':
          SaavnAPI()
              .fetchMoreArtistSongs(
            artistToken: widget.listItem['id'].toString(),
            page: page,
            category: widget.listItem['category'].toString(),
          )
              .then((value) {
            setState(() {
              songList.addAll(value['Top Songs']!);
              fetched = true;
              loading = false;
            });
            if (value['error'] != null) {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
        case 'album':
          SaavnAPI()
              .fetchAlbumSongs(widget.listItem['id'].toString())
              .then((value) {
            setState(() {
              songList = value['songs'] as List;
              fetched = true;
              loading = false;
            });
            if (value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
        case 'playlist':
          SaavnAPI()
              .fetchPlaylistSongs(widget.listItem['id'].toString())
              .then((value) {
            setState(() {
              songList = value['songs'] as List;
              fetched = true;
              loading = false;
            });
            if (value['error'] != null && value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
        case 'mix':
          SaavnAPI()
              .getSongFromToken(
            widget.listItem['perma_url'].toString().split('/').last,
            'mix',
          )
              .then((value) {
            setState(() {
              songList = value['songs'] as List;
              fetched = true;
              loading = false;
            });

            if (value['error'] != null && value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
        case 'show':
          SaavnAPI()
              .getSongFromToken(
            widget.listItem['perma_url'].toString().split('/').last,
            'show',
          )
              .then((value) {
            setState(() {
              songList = [value['show']];
              fetched = true;
              loading = false;
            });

            if (value['error'] != null && value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
        case 'shows':
          SaavnAPI()
              .fetchPodcastSearchResults(
            searchQuery: widget.listItem['id'].toString(),
            page: page,
          )
              .then((value) {
            setState(() {
              songList.addAll(value['shows'] as List);
              fetched = true;
              loading = false;
            });
            if (value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
        case 'season':
          SaavnAPI()
              .getShowEpisodes(
            widget.listItem['id'].toString(),
            page,
            widget.listItem['season_number'].toString(),
          )
              .then((value) {
            setState(() {
              songList.addAll(value['episodes'] as List);
              fetched = true;
              loading = false;
            });

            if (value['error'] != null && value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
        default:
          setState(() {
            fetched = true;
            loading = false;
          });
          ShowSnackBar().showSnackBar(
            context,
            'Error: Unsupported Type ${widget.listItem['type']}',
            duration: const Duration(seconds: 3),
          );
          break;
      }
    } catch (e) {
      setState(() {
        fetched = true;
        loading = false;
      });
      Logger.root.severe(
        'Error in song_list with type ${widget.listItem["type"]}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize =
        MediaQuery.sizeOf(context).height > MediaQuery.sizeOf(context).width
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).height / 2.5;

    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: !fetched
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : BouncyPlaylistHeaderScrollView(
                scrollController: _scrollController,
                actions: [
                  if (songList.isNotEmpty)
                    MultiDownloadButton(
                      data: songList,
                      playlistName:
                          widget.listItem['title']?.toString() ?? 'Songs',
                    ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded),
                    tooltip: AppLocalizations.of(context)!.share,
                    onPressed: () {
                      if (!isSharePopupShown) {
                        isSharePopupShown = true;

                        Share.share(
                          widget.listItem['perma_url'].toString(),
                        ).whenComplete(() {
                          Timer(const Duration(milliseconds: 500), () {
                            isSharePopupShown = false;
                          });
                        });
                      }
                    },
                  ),
                  PlaylistPopupMenu(
                    data: songList,
                    title: widget.listItem['title']?.toString() ?? 'Songs',
                  ),
                ],
                title:
                    widget.listItem['title']?.toString().unescape() ?? 'Songs',
                subtitle: widget.listItem['type'] == 'show'
                    ? widget.listItem['subTitle']?.toString() ??
                        widget.listItem['subtitle']?.toString()
                    : '${songList.length} Songs',
                secondarySubtitle: widget.listItem['type'] == 'show'
                    ? songList[0]['show_details']['header_desc'].toString()
                    : widget.listItem['subTitle']?.toString() ??
                        widget.listItem['subtitle']?.toString(),
                onPlayTap: widget.listItem['type'] == 'show'
                    ? null
                    : () => PlayerInvoke.init(
                          songsList: songList,
                          index: 0,
                          isOffline: false,
                        ),
                onShuffleTap: widget.listItem['type'] == 'show'
                    ? null
                    : () => PlayerInvoke.init(
                          songsList: songList,
                          index: 0,
                          isOffline: false,
                          shuffle: true,
                        ),
                placeholderImage: 'assets/album.png',
                imageUrl: UrlImageGetter([widget.listItem['image']?.toString()])
                    .mediumQuality,
                sliverList: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (songList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            top: 5.0,
                            bottom: 5.0,
                          ),
                          child: Text(
                            widget.listItem['type'] == 'show'
                                ? 'Seasons'
                                : widget.listItem['type'] == 'season'
                                    ? 'Episodes'
                                    : widget.listItem['type'] == 'season'
                                        ? AppLocalizations.of(context)!.podcasts
                                        : AppLocalizations.of(context)!.songs,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      if (widget.listItem['type'] == 'show')
                        SeasonsList(
                          songList[0]['seasons'] as List,
                          widget.listItem['id'].toString(),
                        ),
                      if (widget.listItem['type'] != 'show' &&
                          widget.listItem['type'] != 'season')
                        ...songList.map((entry) {
                          return ListTile(
                            contentPadding: const EdgeInsets.only(left: 15.0),
                            title: Text(
                              '${entry["title"]}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onLongPress: () {
                              copyToClipboard(
                                context: context,
                                text: '${entry["title"]}',
                              );
                            },
                            subtitle: Text(
                              '${entry["subtitle"]}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading:
                                imageCard(imageUrl: entry['image'].toString()),
                            trailing: widget.listItem['type'] == 'shows'
                                ? null
                                : Row(
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
                                  ),
                            onTap: () {
                              widget.listItem['type'] == 'shows'
                                  ? Navigator.push(
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
                                            'id': entry['id'],
                                            'type': entry['type'],
                                            'album': entry['title']
                                                .toString()
                                                .unescape(),
                                            'subtitle':
                                                entry['description'] == null
                                                    ? entry['subtitle']
                                                        .toString()
                                                        .unescape()
                                                    : entry['description']
                                                        .toString()
                                                        .unescape(),
                                            'title': entry['title']
                                                .toString()
                                                .unescape(),
                                            'image': getImageUrl(
                                              entry['image'].toString(),
                                            ),
                                            'perma_url':
                                                entry['perma_url'].toString(),
                                          },
                                        ),
                                      ),
                                    )
                                  : PlayerInvoke.init(
                                      songsList: songList,
                                      index: songList.indexWhere(
                                        (element) => element == entry,
                                      ),
                                      isOffline: false,
                                    );
                            },
                          );
                        }),
                      if (widget.listItem['type'] == 'season')
                        EpisodesList(songList),
                      if (widget.listItem['type'] == 'album')
                        FutureBuilder(
                          future: SaavnAPI().getAlbumRecommendations(
                            widget.listItem['id'].toString(),
                          ),
                          builder: (context, snapshot) => snapshot.hasData
                              ? snapshot.data!.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20.0,
                                            top: 5.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            'Recommendations',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: boxSize + 15,
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              final Map item =
                                                  snapshot.data![index] as Map;
                                              if (item.isEmpty) {
                                                return const SizedBox();
                                              }
                                              return GestureDetector(
                                                onLongPress: () {
                                                  Feedback.forLongPress(
                                                    context,
                                                  );
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return InteractiveViewer(
                                                        child: Stack(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  Navigator.pop(
                                                                context,
                                                              ),
                                                            ),
                                                            AlertDialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  15.0,
                                                                ),
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              content:
                                                                  imageCard(
                                                                borderRadius:
                                                                    15.0,
                                                                imageUrl: item[
                                                                        'image']
                                                                    .toString(),
                                                                imageQuality:
                                                                    ImageQuality
                                                                        .high,
                                                                boxDimension:
                                                                    MediaQuery
                                                                            .sizeOf(
                                                                          context,
                                                                        ).width *
                                                                        0.8,
                                                                placeholderImage:
                                                                    const AssetImage(
                                                                  'assets/album.png',
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      opaque: false,
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              SongsListPage(
                                                        listItem: item,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: SizedBox(
                                                  width: boxSize - 30,
                                                  child: HoverBox(
                                                    child: imageCard(
                                                      margin:
                                                          const EdgeInsets.all(
                                                        4.0,
                                                      ),
                                                      borderRadius: 10.0,
                                                      imageUrl: item['image']
                                                          .toString(),
                                                      imageQuality:
                                                          ImageQuality.medium,
                                                      placeholderImage:
                                                          const AssetImage(
                                                        'assets/album.png',
                                                      ),
                                                    ),
                                                    builder: ({
                                                      required BuildContext
                                                          context,
                                                      required bool isHover,
                                                      Widget? child,
                                                    }) {
                                                      return Card(
                                                        color: isHover
                                                            ? null
                                                            : Colors
                                                                .transparent,
                                                        elevation: 0,
                                                        margin: EdgeInsets.zero,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            10.0,
                                                          ),
                                                        ),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        child: Column(
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                SizedBox.square(
                                                                  dimension: isHover
                                                                      ? boxSize -
                                                                          25
                                                                      : boxSize -
                                                                          30,
                                                                  child: child,
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal:
                                                                    10.0,
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    item['title']
                                                                            ?.toString()
                                                                            .unescape() ??
                                                                        '',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    softWrap:
                                                                        false,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(
                                      height: 0.0,
                                    )
                              : const SizedBox(
                                  height: 0.0,
                                ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
