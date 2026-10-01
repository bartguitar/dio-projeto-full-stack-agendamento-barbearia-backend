package br.com.dio.barber_api.service;

import br.com.dio.barber_api.entity.ScheduleEntity;

public interface IScheduleService {

    ScheduleEntity save(final ScheduleEntity entity);

    void delete(final long id);

}