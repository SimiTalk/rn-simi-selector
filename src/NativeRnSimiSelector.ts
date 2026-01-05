import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  openSelector(options?: Object): Promise<Object[]>;

  openSelectorDefault(): Promise<Object[]>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RnSimiSelector');
