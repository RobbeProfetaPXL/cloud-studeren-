import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of } from 'rxjs';
import { CarrouselComponent } from './carrousel.component';
import { TodoService } from 'src/app/services/todo.service';

class MockTodoService {
  getCarrouselItems() {
    return of([]); // lege lijst is prima voor rooktest
  }
}

describe('CarrouselComponent', () => {
  let component: CarrouselComponent;
  let fixture: ComponentFixture<CarrouselComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [CarrouselComponent],
      providers: [{ provide: TodoService, useClass: MockTodoService }],
    }).compileComponents();

    fixture = TestBed.createComponent(CarrouselComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  afterEach(() => {
    fixture?.destroy(); // triggert ngOnDestroy -> clearInterval
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
