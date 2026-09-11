import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/comment/comment_screen.dart';
import 'package:mindfully_evolve_app/screens/comment/comment_model.dart';
import 'package:mindfully_evolve_app/screens/comment/comment_bloc/comment_bloc.dart';
import 'package:mindfully_evolve_app/screens/comment/comment_bloc/comment_event.dart';
import 'package:mindfully_evolve_app/screens/comment/comment_bloc/comment_state.dart';
import 'package:mindfully_evolve_app/screens/community/community_model.dart';

class FixtureBloc extends CommentBloc {
  FixtureBloc() {
    emit(CommentLoaded(comments: [
      Comment(
          id: 'comment',
          postId: 'post',
          userName: 'A community member with a long name',
          message: 'A peaceful moment today.',
          likesCount: 0,
          liked: false,
          repliesCount: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          replies: [
            Reply(
                id: 'reply',
                postId: 'post',
                parentCommentId: 'comment',
                message: 'Thank you for sharing.',
                likesCount: 0,
                repliesCount: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now())
          ])
    ]));
  }
  PostCommentEvent? sent;
  @override
  void add(CommentEvent event) {
    if (event is PostCommentEvent) {
      sent = event;
      emit(CommentPosting());
    } else {
      super.add(event);
    }
  }
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('Comments reply and input layout, dark=$dark', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = FixtureBloc();
      addTearDown(bloc.close);
      final post = Post(
          id: 'post',
          shareId: '',
          userId: 'author',
          userName: 'Post author',
          message: 'Take a breath.',
          postType: '',
          images: [],
          postAnonymously: false,
          liked: false,
          likesCount: 0,
          commentsCount: 1,
          sharesCount: 0,
          createdAt: DateTime.now());
      await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!),
          home: BlocProvider<CommentBloc>.value(
              value: bloc, child: CommentsContent(post: post))));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('View replies (1)'), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('View replies (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Thank you for sharing.'), findsOneWidget);
      await tester.ensureVisible(find.text('Reply'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'I appreciate this.');
      await tester.tap(find.byTooltip('Send comment'));
      await tester.pump();
      expect(bloc.sent?.parentCommentId, 'comment');
      expect(bloc.sent?.message, 'I appreciate this.');
      final send = tester.widget<IconButton>(find.byType(IconButton).last);
      expect(send.onPressed, isNull);
      expect(tester.takeException(), isNull);
    });
  }
}
