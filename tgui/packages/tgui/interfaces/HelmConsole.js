import { useBackend } from '../backend';
import {
  Button,
  ByondUi,
  LabeledList,
  Section,
  ProgressBar,
  AnimatedNumber,
  Knob,
  LabeledControls,
  NumberInput,
} from '../components';
import { Window } from '../layouts';
import { Table } from '../components/Table';

export const HelmConsole = (_props, context) => {
  const { data } = useBackend(context);
  const { mapRef, isViewer } = data;
  return (
    <Window width={970} height={808} resizable>
      <div className="CameraConsole__left">
        <Window.Content>
          {!isViewer && <ShipControlContent />}
          <ShipContent />
          <SharedContent />
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          {!!data.docked && (
            <div className="NoticeBox">
              Корабль сейчас пристыкован к: {data.docked}
            </div>
          )}
        </div>
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }}
        />
      </div>
    </Window>
  );
};

const SharedContent = (_props, context) => {
  const { act, data } = useBackend(context);
  const { isViewer, shipInfo = [], otherInfo = [] } = data;
  return (
    <>
      <Section
        title={
          <Button.Input
            content={shipInfo.name}
            currentValue={shipInfo.name}
            disabled={isViewer}
            onCommit={(_e, value) =>
              act('rename_ship', {
                newName: value,
              })
            }
          />
        }
        buttons={
          <Button
            tooltip="Обновить статус судна"
            tooltipPosition="left"
            icon="sync"
            disabled={isViewer}
            onClick={() => act('reload_ship')}
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label="Класс">{shipInfo.class}</LabeledList.Item>
          <LabeledList.Item label="Радиус скана">
            <ProgressBar
              value={shipInfo.sensor_range}
              minValue={1}
              maxValue={8}
            >
              <AnimatedNumber value={shipInfo.sensor_range} />
            </ProgressBar>
          </LabeledList.Item>
          {shipInfo.mass && (
            <LabeledList.Item label="Масса">
              {shipInfo.mass + ' тонн'}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section title="Радар">
        <Table>
          <Table.Row bold>
            <Table.Cell>Имя</Table.Cell>
            {!isViewer && <Table.Cell>Цель</Table.Cell>}
          </Table.Row>
          {otherInfo.map((ship) => (
            <Table.Row key={ship.name}>
              <Table.Cell>{ship.name}</Table.Cell>
              {!isViewer && (
                <Table.Cell>
                  <Button
                    tooltip="Начать стыковку"
                    tooltipPosition="left"
                    icon="circle"
                    disabled={
                      // I hate this so much
                      isViewer || data.speed > 0 || data.docked || data.docking
                    }
                    onClick={() =>
                      act('act_overmap', {
                        ship_to_act: ship.ref,
                      })
                    }
                  />
                </Table.Cell>
              )}
            </Table.Row>
          ))}
        </Table>
      </Section>
    </>
  );
};

// Content included on helms when they're controlling ships
const ShipContent = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    isViewer,
    engineInfo,
    estThrust,
    burnPercentage,
    speed,
    heading,
    eta,
    x,
    y,
  } = data;
  return (
    <>
      <Section title="Статус">
        <LabeledList>
          <LabeledList.Item label="Скорость">
            <ProgressBar
              ranges={{
                good: [0, 4],
                average: [4, 7],
                bad: [7, Infinity],
              }}
              maxValue={10}
              value={speed}
            >
              <AnimatedNumber
                value={speed}
                format={(value) => value.toFixed(1)}
              />
              Гм/с
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Направление">
            <AnimatedNumber value={heading} />
          </LabeledList.Item>
          <LabeledList.Item label="Координаты">
            X
            <AnimatedNumber value={x} />
            /Y
            <AnimatedNumber value={y} />
          </LabeledList.Item>
          <LabeledList.Item label="ЕТА">
            <AnimatedNumber value={eta} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Двигатели"
        buttons={
          <Button
            tooltip="Обновить лист двигателей"
            tooltipPosition="left"
            icon="sync"
            disabled={isViewer}
            onClick={() => act('reload_engines')}
          />
        }
      >
        <Table>
          <Table.Row bold>
            <Table.Cell collapsing>Name</Table.Cell>
            <Table.Cell fluid>Fuel</Table.Cell>
          </Table.Row>
          {engineInfo &&
            engineInfo.map((engine) => (
              <Table.Row key={engine.name} className="candystripe">
                <Table.Cell collapsing>
                  <Button
                    content={
                      engine.name.len < 14
                        ? engine.name
                        : engine.name.slice(0, 10) + '...'
                    }
                    color={engine.enabled && 'good'}
                    icon={engine.enabled ? 'toggle-on' : 'toggle-off'}
                    disabled={isViewer}
                    tooltip="Toggle Engine"
                    tooltipPosition="right"
                    onClick={() =>
                      act('toggle_engine', {
                        engine: engine.ref,
                      })
                    }
                  />
                </Table.Cell>
                <Table.Cell fluid>
                  {!!engine.maxFuel && (
                    <ProgressBar
                      fluid
                      ranges={{
                        good: [50, Infinity],
                        average: [25, 50],
                        bad: [-Infinity, 25],
                      }}
                      maxValue={engine.maxFuel}
                      minValue={0}
                      value={engine.fuel}
                    >
                      <AnimatedNumber
                        value={(engine.fuel / engine.maxFuel) * 100}
                        format={(value) => Math.round(value)}
                      />
                      %
                    </ProgressBar>
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
          <Table.Row>
            <Table.Cell>Max thrust per second:</Table.Cell>
            <Table.Cell>
              <AnimatedNumber
                value={estThrust * 500}
                format={(value) => value.toFixed(2)}
              />
              Gm/s²
            </Table.Cell>
          </Table.Row>
        </Table>
      </Section>
    </>
  );
};

// Arrow directional controls
const ShipControlContent = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    calibrating,
    aiControls,
    aiUser,
    burnDirection,
    burnPercentage,
    speed,
    estThrust,
  } = data;
  let flyable = !data.docking && !data.docked;

  //  DIRECTIONS const idea from Lyra as part of their Haven-Urist project
  const DIRECTIONS = {
    north: 1,
    south: 2,
    east: 4,
    west: 8,
    northeast: 1 + 4,
    northwest: 1 + 8,
    southeast: 2 + 4,
    southwest: 2 + 8,
    stop: -1,
  };
  return (
    <Section
      title="Управление"
      buttons={
        <>
          <Button
            tooltip="Отстыковка"
            tooltipPosition="left"
            icon="sign-out-alt"
            disabled={!data.docked || data.docking}
            onClick={() => act('undock')}
          />
          <Button
            tooltip="Пристыковка в пустое место"
            tooltipPosition="left"
            icon="sign-in-alt"
            disabled={!flyable}
            onClick={() => act('dock_empty')}
          />
          <Button
            tooltip={calibrating ? 'Отменить прыжок' : 'Запустить прыжок'}
            tooltipPosition="left"
            icon={calibrating ? 'times' : 'angle-double-right'}
            color={calibrating ? 'bad' : undefined}
            disabled={!flyable}
            onClick={() => act('bluespace_jump')}
          />
          <Button
            tooltip={aiControls ? 'Отключить удалённый доступ' : 'Включить удалённый доступ'}
            tooltipPosition="left"
            icon={aiControls ? 'toggle-on' : 'toggle-off'}
            color={aiControls ? 'green' : 'red'}
            disabled={aiUser}
            onClick={() => act('toggle_ai_control')}
          />
        </>
      }
    >
      <LabeledControls>
        <LabeledControls.Item label="Direction" width={'50%'}>
          <Table collapsing>
            <Table.Row height={1}>
              <Table.Cell width={1}>
                <Button
                  icon="arrow-left"
                  iconRotation={45}
                  mb={1}
                  color={burnDirection === DIRECTIONS.northwest && 'good'}
                  disabled={!flyable}
                  onClick={() =>
                    act('change_heading', {
                      dir: DIRECTIONS.northwest,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell width={1}>
                <Button
                  icon="arrow-up"
                  mb={1}
                  color={burnDirection === DIRECTIONS.north && 'good'}
                  disabled={!flyable}
                  onClick={() =>
                    act('change_heading', {
                      dir: DIRECTIONS.north,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell width={1}>
                <Button
                  icon="arrow-right"
                  iconRotation={-45}
                  mb={1}
                  color={burnDirection === DIRECTIONS.northeast && 'good'}
                  disabled={!flyable}
                  onClick={() =>
                    act('change_heading', {
                      dir: DIRECTIONS.northeast,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row height={1}>
              <Table.Cell width={1}>
                <Button
                  icon="arrow-left"
                  mb={1}
                  color={burnDirection === DIRECTIONS.west && 'good'}
                  disabled={!flyable}
                  onClick={() =>
                    act('change_heading', {
                      dir: DIRECTIONS.west,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell width={1}>
                <Button
                  tooltip={burnDirection === 0 ? 'Slow down' : 'Stop thrust'}
                  icon={
                    burnDirection === 0 || burnDirection === DIRECTIONS.stop
                      ? 'stop'
                      : 'pause'
                  }
                  mb={1}
                  color={burnDirection === DIRECTIONS.stop && 'good'}
                  disabled={!flyable || (burnDirection === 0 && !speed)}
                  onClick={() => act('stop')}
                />
              </Table.Cell>
              <Table.Cell width={1}>
                <Button
                  icon="arrow-right"
                  mb={1}
                  color={burnDirection === DIRECTIONS.east && 'good'}
                  disabled={!flyable}
                  onClick={() =>
                    act('change_heading', {
                      dir: DIRECTIONS.east,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row height={1}>
              <Table.Cell width={1}>
                <Button
                  icon="arrow-left"
                  iconRotation={-45}
                  mb={1}
                  color={burnDirection === DIRECTIONS.southwest && 'good'}
                  disabled={!flyable}
                  onClick={() =>
                    act('change_heading', {
                      dir: DIRECTIONS.southwest,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell width={1}>
                <Button
                  icon="arrow-down"
                  mb={1}
                  color={burnDirection === DIRECTIONS.south && 'good'}
                  disabled={!flyable}
                  onClick={() =>
                    act('change_heading', {
                      dir: DIRECTIONS.south,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell width={1}>
                <Button
                  icon="arrow-right"
                  iconRotation={45}
                  mb={1}
                  color={burnDirection === DIRECTIONS.southeast && 'good'}
                  disabled={!flyable}
                  onClick={() =>
                    act('change_heading', {
                      dir: DIRECTIONS.southeast,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </LabeledControls.Item>
        <LabeledControls.Item label="Throttle">
          <Knob
            value={burnPercentage}
            minValue={1}
            step={1}
            maxValue={100}
            size={2}
            unit="%"
            onDrag={(e, value) =>
              act('change_burn_percentage', {
                percentage: value,
              })
            }
            animated
          />
          <NumberInput
            value={(burnPercentage / 100) * estThrust * 500}
            minValue={0.01}
            step={0.01}
            // 5 times a second, 60 seconds in a minute (5 * 60 = 300)
            maxValue={estThrust * 500}
            unit="Gm/s²"
            onDrag={(e, value) =>
              act('change_burn_percentage', {
                percentage: Math.round((value / (estThrust * 500)) * 100),
              })
            }
            format={(value) => value.toFixed(2)}
            animated
            fluid
          />
        </LabeledControls.Item>
      </LabeledControls>
    </Section>
  );
};
