import 'package:flowy_sdk/protobuf/flowy-grid/field_entities.pb.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'type_option/type_option_context.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'type_option/type_option_data_controller.dart';

part 'field_editor_bloc.freezed.dart';

class FieldEditorBloc extends Bloc<FieldEditorEvent, FieldEditorState> {
  final TypeOptionDataController dataController;

  FieldEditorBloc({
    required String gridId,
    required String fieldName,
    required IFieldTypeOptionLoader loader,
  })  : dataController =
            TypeOptionDataController(gridId: gridId, loader: loader),
        super(FieldEditorState.initial(gridId, fieldName)) {
    on<FieldEditorEvent>(
      (event, emit) async {
        await event.when(
          initial: () async {
            dataController.addFieldListener((field) {
              if (!isClosed) {
                add(FieldEditorEvent.didReceiveFieldChanged(field));
              }
            });
            await dataController.loadTypeOptionData();
          },
          updateName: (name) {
            dataController.fieldName = name;
            emit(state.copyWith(name: name));
          },
          didReceiveFieldChanged: (FieldPB field) {
            emit(state.copyWith(field: Some(field)));
          },
        );
      },
    );
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}

@freezed
class FieldEditorEvent with _$FieldEditorEvent {
  const factory FieldEditorEvent.initial() = _InitialField;
  const factory FieldEditorEvent.updateName(String name) = _UpdateName;
  const factory FieldEditorEvent.didReceiveFieldChanged(FieldPB field) =
      _DidReceiveFieldChanged;
}

@freezed
class FieldEditorState with _$FieldEditorState {
  const factory FieldEditorState({
    required String gridId,
    required String errorText,
    required String name,
    required Option<FieldPB> field,
  }) = _FieldEditorState;

  factory FieldEditorState.initial(
    String gridId,
    String fieldName,
  ) =>
      FieldEditorState(
        gridId: gridId,
        errorText: '',
        field: none(),
        name: fieldName,
      );
}
