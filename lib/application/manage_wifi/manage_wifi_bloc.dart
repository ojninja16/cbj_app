import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cybear_jinni/domain/home_user/home_user_failures.dart';
import 'package:cybear_jinni/domain/manage_wifi/i_manage_wifi_repository.dart';
import 'package:cybear_jinni/domain/manage_wifi/manage_wifi_entity.dart';
import 'package:cybear_jinni/domain/manage_wifi/manage_wifi_value_objects.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/kt.dart';
import 'package:meta/meta.dart';

part 'manage_wifi_bloc.freezed.dart';
part 'manage_wifi_event.dart';
part 'manage_wifi_state.dart';

@injectable
class ManageWifiBloc extends Bloc<ManageWifiEvent, ManageWifiState> {
  ManageWifiBloc(this._manageWiFiRepository) : super(ManageWifiState.initial());

  final IManageWiFiRepository _manageWiFiRepository;

  ManageWiFiName wifiName;
  ManageWiFiPass wifiPassword;

  @override
  Stream<ManageWifiState> mapEventToState(
    ManageWifiEvent event,
  ) async* {
    yield* event.map(
      initialized: (e) async* {
        yield ManageWifiState.loading();

        final Either<HomeUserFailures, Unit> doesWiFiEnabled =
            await _manageWiFiRepository.doesWiFiEnabled();

        yield doesWiFiEnabled.fold(
          (f) => ManageWifiState.wifiIsDisabled(),
          (r) => ManageWifiState.wifiIsEnabled(),
        );
      },
      scanForWiFiNetworks: (e) async* {
        yield ManageWifiState.loading();

        final Stream<Either<HomeUserFailures, KtList<ManageWiFiEntity>>>
            doesWiFiEnabled = _manageWiFiRepository.scanWiFiNetworks();

        // doesWiFiEnabled.fold(
        //   (f) => const ManageWifiState.wifiIsDisabled(),
        //   (r) => const ManageWifiState.wifiIsEnabled(),
        // );
      },
      connectToWiFi: (e) async* {
        yield ManageWifiState.loading();

        ManageWiFiEntity manageWiFiEntity = ManageWiFiEntity(
          name: wifiName,
          passpass: wifiPassword,
        );

        final Either<HomeUserFailures, Unit> doesWiFiEnabled =
            await _manageWiFiRepository.connectToWiFi(manageWiFiEntity);

        yield doesWiFiEnabled.fold(
          (f) => ManageWifiState.error(),
          (r) => ManageWifiState.loaded(),
        );
      },
      wifiSsidChanged: (value) async* {
        wifiName = ManageWiFiName(value.wifiSsidStr);
      },
      wifiPassChanged: (value) async* {
        wifiPassword = ManageWiFiPass(value.wifiPassStr);
      },
    );
  }
}
