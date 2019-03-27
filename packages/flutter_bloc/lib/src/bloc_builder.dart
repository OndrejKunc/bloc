import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';

/// A function that will be run which takes the [BuildContext] and state
/// and is responsible for returning a [Widget] which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// A function constructing subset of the state
typedef StateConverter<S, ViewModel> = ViewModel Function(S state);

/// A Flutter widget which requires a [Bloc] and a [BlocWidgetBuilder] `builder` function.
/// [BlocBuilder] handles building the widget in response to new states.
/// BlocBuilder analogous to [StreamBuilder] but has simplified API
/// to reduce the amount of boilerplate code needed
/// as well as bloc-specific performance improvements.
class BlocBuilder<E, S> extends BlocBuilderBase<E, S, S> {
  final Bloc<E, S> bloc;
  final BlocWidgetBuilder<S> builder;

  const BlocBuilder({Key key, @required this.bloc, @required this.builder})
      : assert(bloc != null),
        assert(builder != null),
        super(key: key, bloc: bloc);

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

class BlocProjectionBuilder<E, S, ViewModel>
    extends BlocBuilderBase<E, S, ViewModel> {
  final Bloc<E, S> bloc;
  final BlocWidgetBuilder<ViewModel> builder;
  final StateConverter<S, ViewModel> converter;
  final bool distinct;

  const BlocProjectionBuilder(
      {Key key,
      @required this.bloc,
      @required this.builder,
      @required this.converter,
      this.distinct = true})
      : assert(bloc != null),
        assert(builder != null),
        assert(converter != null),
        super(key: key, bloc: bloc, converter: converter, distinct: distinct);

  @override
  Widget build(BuildContext context, ViewModel state) =>
      builder(context, state);
}

/// Base class for widgets that build themselves based on interaction with
/// a specified [Bloc].
///
/// A [BlocBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
abstract class BlocBuilderBase<E, S, ViewModel> extends StatefulWidget {
  const BlocBuilderBase(
      {Key key, this.bloc, this.converter, this.distinct = true})
      : super(key: key);

  /// The [Bloc] that the [BlocBuilderBase] will interact with.
  final Bloc<E, S> bloc;

  final StateConverter<S, ViewModel> converter;
  final bool distinct;

  /// Returns a [Widget] based on the [BuildContext] and current [state].
  Widget build(BuildContext context, ViewModel state);

  @override
  State<BlocBuilderBase<E, S, ViewModel>> createState() =>
      _BlocBuilderBaseState<E, S, ViewModel>();
}

class _BlocBuilderBaseState<E, S, ViewModel>
    extends State<BlocBuilderBase<E, S, ViewModel>> {
  StreamSubscription<ViewModel> _subscription;
  ViewModel _state;

  @override
  void initState() {
    super.initState();
    _state = _convert(widget.bloc.currentState);
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocBuilderBase<E, S, ViewModel> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc.state != widget.bloc.state) {
      if (_subscription != null) {
        _unsubscribe();
        _state = _convert(widget.bloc.currentState);
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _state);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (widget.bloc.state != null) {
      var stream = widget.bloc.state.skip(1).map((state) => _convert(state));
      if (widget.distinct) {
        stream = stream.distinct();
      }
      _subscription = stream.listen((ViewModel state) {
        setState(() {
          _state = state;
        });
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  /// Since dart doesn't support constant function literals
  /// we can't pass identity to const constructor so we
  /// assume identity was passed when `widget.converter` is null
  ViewModel _convert(S state) {
    return widget.converter != null
        ? widget.converter(state)
        : state as ViewModel;
  }
}
