import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/attendance_service_line.dart';
import 'package:lava_cash/core/domain/entities/service_record.dart';
import 'package:lava_cash/core/domain/entities/vehicle_with_client.dart';

abstract class ServiceRepository {
  Future<Either<Failure, VehicleWithClient>> getVehicleWithClient(
    String vehicleId,
  );

  Future<Either<Failure, ServiceRecord>> getServiceById(String serviceId);

  Future<Either<Failure, ServiceRecord>> startService(String vehicleId);

  Future<Either<Failure, ServiceRecord>> updateServiceDetails({
    required String serviceId,
    required double valor,
    String? nomeServico,
    String? observacao,
  });

  Future<Either<Failure, Unit>> cancelService(String serviceId);

  Future<Either<Failure, List<AttendanceServiceLine>>> listAttendanceServiceLines(
    String atendimentoId,
  );

  Future<Either<Failure, AttendanceServiceLine>> addAttendanceServiceLine({
    required String atendimentoId,
    String? servicoCatalogoId,
    required String nome,
    required double valor,
    String? observacao,
  });

  Future<Either<Failure, AttendanceServiceLine>> updateAttendanceServiceLine({
    required String lineId,
    required String nome,
    required double valor,
    String? observacao,
  });

  Future<Either<Failure, Unit>> deleteAttendanceServiceLine(String lineId);
}
