import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/models/community_post.dart';
import 'package:mygate_coepd/models/marketplace_item.dart';
import 'package:mygate_coepd/repositories/community_repository.dart';

// --- Events ---
abstract class CommunityEvent {}

class LoadCommunityData extends CommunityEvent {}

class CreateCommunityPost extends CommunityEvent {
  final String content;
  final String? image;

  CreateCommunityPost({required this.content, this.image});
}

class LikeCommunityPost extends CommunityEvent {
  final int postId;

  LikeCommunityPost(this.postId);
}

class DeleteCommunityPost extends CommunityEvent {
  final int postId;

  DeleteCommunityPost(this.postId);
}

class CommentOnCommunityPost extends CommunityEvent {
  final int postId;
  final String content;

  CommentOnCommunityPost(this.postId, this.content);
}

// --- States ---
abstract class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<CommunityPost> posts;
  final List<MarketplaceItem> marketplaceItems;

  CommunityLoaded({required this.posts, required this.marketplaceItems});

  CommunityLoaded copyWith({
    List<CommunityPost>? posts,
    List<MarketplaceItem>? marketplaceItems,
  }) {
    return CommunityLoaded(
      posts: posts ?? this.posts,
      marketplaceItems: marketplaceItems ?? this.marketplaceItems,
    );
  }
}

class CommunityError extends CommunityState {
  final String message;

  CommunityError(this.message);
}

// --- BLoC ---
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository _repository;

  CommunityBloc(this._repository) : super(CommunityInitial()) {
    on<LoadCommunityData>(_onLoadCommunityData);
    on<CreateCommunityPost>(_onCreateCommunityPost);
    on<LikeCommunityPost>(_onLikeCommunityPost);
    on<DeleteCommunityPost>(_onDeleteCommunityPost);
    on<CommentOnCommunityPost>(_onCommentOnCommunityPost);
  }

  Future<void> _onLoadCommunityData(LoadCommunityData event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      final posts = await _repository.getPosts();
      final items = await _repository.getMarketplaceItems();
      emit(CommunityLoaded(posts: posts, marketplaceItems: items));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onCreateCommunityPost(CreateCommunityPost event, Emitter<CommunityState> emit) async {
    final currentState = state;
    try {
      await _repository.createPost(event.content, image: event.image);
      add(LoadCommunityData());
    } catch (e) {
      emit(CommunityError(e.toString()));
      if (currentState is CommunityLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onLikeCommunityPost(LikeCommunityPost event, Emitter<CommunityState> emit) async {
    final currentState = state;
    if (currentState is CommunityLoaded) {
      try {
        // Optimistic UI update
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return CommunityPost(
              id: post.id,
              userId: post.userId,
              userName: post.userName,
              content: post.content,
              time: post.time,
              userAvatar: post.userAvatar,
              unit: post.unit,
              image: post.image,
              commentsCount: post.commentsCount,
              hasLiked: !post.hasLiked,
              likesCount: post.hasLiked ? post.likesCount - 1 : post.likesCount + 1,
            );
          }
          return post;
        }).toList();
        
        emit(currentState.copyWith(posts: updatedPosts));
        
        await _repository.likePost(event.postId);
      } catch (e) {
        // Revert on error
        emit(CommunityError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteCommunityPost(DeleteCommunityPost event, Emitter<CommunityState> emit) async {
    final currentState = state;
    if (currentState is CommunityLoaded) {
      try {
        await _repository.deletePost(event.postId);
        
        final updatedPosts = currentState.posts.where((post) => post.id != event.postId).toList();
        emit(currentState.copyWith(posts: updatedPosts));
      } catch (e) {
        emit(CommunityError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onCommentOnCommunityPost(CommentOnCommunityPost event, Emitter<CommunityState> emit) async {
    final currentState = state;
    if (currentState is CommunityLoaded) {
      try {
        await _repository.commentOnPost(event.postId, event.content);
        
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return CommunityPost(
              id: post.id,
              userId: post.userId,
              userName: post.userName,
              content: post.content,
              time: post.time,
              userAvatar: post.userAvatar,
              unit: post.unit,
              image: post.image,
              commentsCount: post.commentsCount + 1,
              hasLiked: post.hasLiked,
              likesCount: post.likesCount,
            );
          }
          return post;
        }).toList();
        
        emit(currentState.copyWith(posts: updatedPosts));
      } catch (e) {
        emit(CommunityError(e.toString()));
        emit(currentState);
      }
    }
  }
}
