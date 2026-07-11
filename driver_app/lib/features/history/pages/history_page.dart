import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/history_bloc.dart';
import '../repository/history_repository.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated. Please sign in again.')),
      );
    }
    return BlocProvider(
      create: (context) => HistoryBloc(
        repository: HistoryRepository(Supabase.instance.client),
        userId: userId,
      )..add(LoadHistory()),
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip History')),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HistoryLoaded) {
            return ListView.builder(
              itemCount: state.rides.length,
              itemBuilder: (context, index) {
                final ride = state.rides[index];
                return ListTile(
                  title: Text(ride.dropoffAddress),
                  subtitle: Text(ride.completedAt.toString()),
                  trailing: Text(ride.fare != null ? 'R${ride.fare}' : 'N/A'),
                );
              },
            );
          }
          if (state is HistoryError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No history found'));
        },
      ),
    );
  }
}
